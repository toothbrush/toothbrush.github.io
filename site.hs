--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

import Control.Applicative ((<$>))
import Data.Monoid         (mappend)
import Hakyll
import Data.Char (toUpper, toLower)
import Text.Printf
import Data.Time.Clock
import Data.Ord (comparing)
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
 do (y,m,d) <- fmap (toGregorian . utctDay) getCurrentTime

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

      match "pubs/*.md" $ do
          route $ setExtension "html"
          compile $ pandocCompiler
              >>= loadAndApplyTemplate "templates/pub.html"    articleDateCtx
              >>= loadAndApplyTemplate "templates/default.html" (articleDateCtx `mappend` myCtx y m d)
              >>= relativizeUrls

      -- Recipes by tag
      tagsRules tags $ \tag pat -> do
        let title = "Recipes tagged '" ++ tag ++ "'"
        route idRoute
        compile $ do
          list <- byTitle =<< loadAll pat
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
              let bodyPieces = concat <$> mapM (\ t -> do
                                      list <- recipeList tags (explorePattern tags t)
                                      return $ "<h2>" ++ capWord t ++ "</h2>" ++ "<ul>" ++ list ++ "</ul>"
                                    ) allTags
              makeItem ""
                  >>= withItemBody (const bodyPieces)
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
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
              let indexCtx = field "pubs" (const (pubList 3))
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
  field "modified" (\item -> return $ printf "%d/%s/%d" d (months !! (m - 1)) y) `mappend`
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
    all     <- byTitle =<< loadAll "recipes/*.md"
    let pubs = case recent of
                    Nothing -> all
                    Just recent -> take recent all
    itemTpl <- loadBody "templates/recipe-item.html"
    applyTemplateList itemTpl defaultContext (sortBy (compare `on` itemIdentifier) pubs)

--------------------------------------------------------------------------------
pubList :: Int -> Compiler String
pubList n = do
    pubs    <- loadAll "pubs/*.md" >>= recentFirst
    itemTpl <- loadBody "templates/pub-item.html"
    case n of 0 -> applyTemplateList itemTpl articleDateCtx pubs
              n -> applyTemplateList itemTpl articleDateCtx (take n pubs)

-- fetch all recipes and sort alphabetically.
recipeList :: Tags -> Pattern ->  Compiler String
recipeList tags pat = do
    postItemTpl <- loadBody "templates/recipe-item.html"
    posts <- byTitle =<< loadAll pat
    applyTemplateList postItemTpl (tagsCtx tags) posts

-- this parses the coolness out of an item
-- it defaults to 0 if it's missing, or can't be parsed as an Int
--
-- Inspiration from https://stackoverflow.com/questions/62714654/sort-hakyll-item-list-by-a-custom-field
titleExtract :: MonadMetadata m => Item a -> m String
titleExtract i = do
    mStr <- getMetadataField (itemIdentifier i) "title"
    let title = fromJust mStr
    return title

byTitle :: MonadMetadata m => [Item a] -> m [Item a]
byTitle = sortByM titleExtract
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = liftM (map fst . sortBy (comparing snd)) $
                   mapM (\x -> liftM (x,) (f x)) xs

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
postList pat postCtx sortFilter = do
                       posts   <- sortFilter =<< loadAll pat
                       itemTpl <- loadBody "templates/recipe-item.html"
                       applyTemplateList itemTpl postCtx posts

capWord :: String -> String
capWord word = case word of
  [] -> []
  (h:t) -> toUpper h : map toLower t
