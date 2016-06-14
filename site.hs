--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Control.Applicative ((<$>))
import Data.Monoid         (mappend)
import Hakyll
import Data.Char (toUpper, toLower)
import Text.Printf
import Data.Time.Clock
import Data.Time.Calendar
import Data.Function (on)
import Control.Monad (liftM)
import Control.Monad.Reader
import Control.Monad.Logger
import Data.List
import Data.List.Split
import Data.ByteString (ByteString)
import Data.Maybe
import Data.Text.Encoding (encodeUtf8)
import qualified Data.Text as T

import Debug.Trace

--------------------------------------------------------------------------------
main :: IO ()
main =
 do (y,m,d) <- liftM (toGregorian . utctDay) getCurrentTime 

    hakyll $ do

      -- Build tags for recipes
      tags <- buildTags "recipes/*.md" (fromCapture "recipes/tags/*.html")

      -- some things should just be copied verbatim
      match ( "images/*"
         .||. "bib/*"
         .||. "pdf/*" ) $ do
          route   idRoute
          compile copyFileCompiler

      match "css/*.css" $ do
        route idRoute
        compile compressCssCompiler
   
      -- TODO: all of this stuff needs de-duplication, it's awfully similar
      match "recipes/*.md" $ do
          route $ setExtension "html"
          compile $ do
                  let sbCtx = 
                         tagsCtx tags `mappend`
                         myCtx y m d
                  pandocCompiler
                         >>= loadAndApplyTemplate "templates/recipe-body.html"  sbCtx
                         >>= loadAndApplyTemplate "templates/default.html" sbCtx
                         >>= relativizeUrls
   
      match "soapbox/*.md" $ do
          route $ setExtension "html"
          compile $ do
                  let sbCtx = 
                         articleDateCtx `mappend`
                         myCtx y m d
                  pandocCompiler
                         >>= loadAndApplyTemplate "templates/sb-body.html"  sbCtx
                         >>= loadAndApplyTemplate "templates/default.html" sbCtx
                         >>= relativizeUrls
   
      match "pubs/*.md" $ do
          route $ setExtension "html"
          compile $ pandocCompiler
              >>= loadAndApplyTemplate "templates/pub.html"    articleDateCtx
              >>= loadAndApplyTemplate "templates/default.html" (articleDateCtx `mappend` myCtx y m d)
              >>= relativizeUrls
   
      -- Post tags
      tagsRules tags $ \tag pattern -> do
        let title = "Recipes tagged '" ++ tag ++ "'"
        route idRoute
        compile $ do
          list <- loadAll pattern
          let archiveCtx = 
                constField "title" title `mappend`
                myCtx y m d
          makeItem ""
             >>= loadAndApplyTemplate "templates/recipes-for-index.html"
                 (constField "title" title `mappend`
                  listField "recipes" (tagsCtx tags) (return list) `mappend`
                  archiveCtx)
             >>= loadAndApplyTemplate "templates/default.html" archiveCtx
             >>= relativizeUrls


      create ["recipes/index.html", "recipes-index.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx = 
                      constField "title" "Recipes by tag"  `mappend`
                      myCtx y m d
              let allTags = map fst (tagsMap tags)
              -- TODO should probably use template system here
              let bodyPieces = liftM concat $ mapM (\ t -> do
                                      list <- recipeList tags (explorePattern tags t)
                                      return $ "<h2>" ++ capWord t ++ "</h2>" ++ "<ul>" ++ list ++ "</ul>"
                                    ) allTags
              makeItem ""
                  >>= withItemBody (const bodyPieces)
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
              
      create ["soapbox/index.html", "soapbox-index.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx =
                      field "soaps" (\_ -> sbIndex Nothing) `mappend`
                      constField "title" "Soapbox"  `mappend`
                      myCtx y m d `mappend`
                      articleDateCtx
              makeItem ""
                  >>= loadAndApplyTemplate "templates/soapbox-index.html" archiveCtx
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
   
      create ["soapbox.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx = myCtx y m d
              (pub:_) <- loadAll "soapbox/*.md" >>= recentFirst
              makeItem (itemBody pub)
                  >>= relativizeUrls
   
      create ["pubs/index.html", "pubs.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx =
                      field "pubs" (const (pubList 0))       `mappend`
                      constField "title" "Publications"  `mappend`
                      myCtx y m d
   
              makeItem ""
                  >>= loadAndApplyTemplate "templates/pubs.html" archiveCtx
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
   
   
      match (fromList ["index.html", "projects.html"]) $ do
          route idRoute
          compile $ do
              let indexCtx = field "pubs" (const (pubList 3)) `mappend`
                      field "soaps" (\_ -> sbIndex $ Just 3)
              getResourceBody
                  >>= applyAsTemplate indexCtx
                  >>= loadAndApplyTemplate "templates/default.html" (articleDateCtx `mappend` myCtx y m d)
                  >>= relativizeUrls
   
      match "templates/*" $ compile templateCompiler

      
--------------------------------------------------------------------------------
articleDateCtx :: Context String
articleDateCtx =
    dateField "date" "%e %B, %Y" `mappend`
    defaultContext

myCtx :: Integer -> Int -> Int -> Context String
myCtx y m d =
  field "modified" (\item -> return $ printf "%d/%s/%d" d ( months !! (m - 1)) y) `mappend` 
  defaultContext

months :: [String]
months = ["Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec"
         ]
--------------------------------------------------------------------------------
recipesIndex :: Maybe Int -> Compiler String
recipesIndex recent = do
    all     <- loadAll "recipes/*.md" 
    let pubs = case recent of
                    Nothing -> all
                    Just recent -> take recent all
    itemTpl <- loadBody "templates/recipe-item.html"
    applyTemplateList itemTpl defaultContext (sortBy (compare `on` itemIdentifier) pubs)
    
--------------------------------------------------------------------------------
sbIndex :: Maybe Int -> Compiler String
sbIndex recent = do
    all     <- loadAll "soapbox/*.md" >>= recentFirst
    let pubs = case recent of
                    Nothing -> all
                    Just recent -> take recent all
    itemTpl <- loadBody "templates/sb-item.html"
    applyTemplateList itemTpl articleDateCtx pubs
   
--------------------------------------------------------------------------------
pubList :: Int -> Compiler String
pubList n = do
    pubs    <- loadAll "pubs/*.md" >>= recentFirst
    itemTpl <- loadBody "templates/pub-item.html"
    case n of 0 -> applyTemplateList itemTpl articleDateCtx pubs
              n -> applyTemplateList itemTpl articleDateCtx (take n pubs)

-- fetch all recipes and sort alphabetically.
recipeList :: Tags -> Pattern ->  Compiler String
recipeList tags pattern = do
    postItemTpl <- loadBody "templates/recipe-item.html"
    posts <- loadAll pattern
    applyTemplateList postItemTpl (tagsCtx tags) (sortBy (compare `on` itemIdentifier) posts)

tagsCtx :: Tags -> Context String
tagsCtx tags =
  tagsField "prettytags" tags `mappend`
  defaultContext

-- | Builds a pattern to match only posts tagged with a given primary tag.
explorePattern :: Tags -> String -> Pattern
explorePattern tags primaryTag = fromList identifiers
  where identifiers = fromMaybe [] $ lookup primaryTag (tagsMap tags)


-- | Creates a compiler to render a list of posts for a given pattern, context,
-- and sorting/filtering function
postList :: Pattern
         -> Context String
         -> ([Item String] -> Compiler [Item String])
         -> Compiler String
postList pattern postCtx sortFilter = do
                       posts   <- sortFilter =<< loadAll pattern
                       itemTpl <- loadBody "templates/recipe-item.html"
                       applyTemplateList itemTpl postCtx posts

capWord :: String -> String
capWord word = case word of
  [] -> []
  (h:t) -> toUpper h : map toLower t
