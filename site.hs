--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Control.Applicative ((<$>))
import Data.Monoid         (mappend)
import Hakyll
import Text.Printf
import Data.Time.Clock
import Data.Time.Calendar
import Data.Function (on)
import Control.Monad (liftM)
import Control.Monad.Reader
import Control.Monad.Logger
import Data.List
import Data.List.Split
import Git
import Git.Libgit2
import Data.ByteString (ByteString)
import Data.Maybe
import Data.Text.Encoding (encodeUtf8)
import qualified Data.Text as T
import System.Directory
import Filesystem.Path.CurrentOS


data Recipe = R String -- title
                [String] -- tags
                String -- body
instance Show Recipe where
  show (R title ts bod) = "R " ++ title ++ ", tags="++show ts++ ", "++ take 40 bod ++ "\n"
--------------------------------------------------------------------------------
main :: IO ()
main =
 do (y,m,d) <- liftM (toGregorian . utctDay) getCurrentTime 

    -- this ugliness retrieves the current git commit hash.
    path <- getCurrentDirectory
    let repoOpts = RepositoryOptions { repoPath = path
                                     , repoWorkingDir = Nothing
                                     , repoIsBare = False
                                     , repoAutoCreate = False
                                     }
    repo <- liftIO $ openLgRepository repoOpts
    commitFromRef <- liftIO $ runStderrLoggingT
                            $ runLgRepository repo
                                (do let masterRef = "refs/heads/master"
                                    Just ref <- resolveReference masterRef
                                    return ref)
    let hash = show commitFromRef
    -- end git ugliness

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
                         myCtx y m d hash
                  pandocCompiler
                         >>= loadAndApplyTemplate "templates/recipe-body.html"  sbCtx
                         >>= loadAndApplyTemplate "templates/default.html" sbCtx
                         >>= relativizeUrls
   
      match "soapbox/*.md" $ do
          route $ setExtension "html"
          compile $ do
                  let sbCtx = 
                         articleDateCtx `mappend`
                         myCtx y m d hash
                  pandocCompiler
                         >>= loadAndApplyTemplate "templates/sb-body.html"  sbCtx
                         >>= loadAndApplyTemplate "templates/default.html" sbCtx
                         >>= relativizeUrls
   
      match "pubs/*.md" $ do
          route $ setExtension "html"
          compile $ pandocCompiler
              >>= loadAndApplyTemplate "templates/pub.html"    articleDateCtx
              >>= loadAndApplyTemplate "templates/default.html" (articleDateCtx `mappend` myCtx y m d hash)
              >>= relativizeUrls
   
      -- Post tags
      tagsRules tags $ \tag pattern -> do
        let title = "Recipes tagged '" ++ tag ++ "'"
        route idRoute
        compile $ do
          list <- postList tags pattern recentFirst
          let archiveCtx = 
                constField "body" list `mappend`
                constField "title" title `mappend`
                myCtx y m d hash
          makeItem ""
             >>= loadAndApplyTemplate "templates/recipes-index.html" archiveCtx
             >>= loadAndApplyTemplate "templates/default.html" archiveCtx
             >>= relativizeUrls

      create ["recipes/index.html", "recipes-index.html"] $ do
          route idRoute
          compile $ do
              -- rs <- recipes
              let archiveCtx = 
                      -- field "recipes" (const $ recipesIndex Nothing) `mappend`
                      --field "recipes" getRecipesForTag `mappend`
                      constField "title" "Recipes"  `mappend`
                      tagsField "tags" tags `mappend`
                      myCtx y m d hash
              list <- postList tags "recipes/*.md" recentFirst
              --error (show list)
              makeItem list
                  >>= loadAndApplyTemplate "templates/recipes-index.html" archiveCtx
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
   
      create ["soapbox/index.html", "soapbox-index.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx =
                      field "soaps" (\_ -> sbIndex Nothing) `mappend`
                      constField "title" "Soapbox"  `mappend`
                      myCtx y m d hash `mappend`
                      articleDateCtx
              makeItem ""
                  >>= loadAndApplyTemplate "templates/soapbox-index.html" archiveCtx
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
   
      create ["soapbox.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx = myCtx y m d hash
              (pub:_) <- loadAll "soapbox/*.md" >>= recentFirst
              makeItem (itemBody pub)
                  >>= relativizeUrls
   
      create ["pubs/index.html", "pubs.html"] $ do
          route idRoute
          compile $ do
              let archiveCtx =
                      field "pubs" (const pubList)       `mappend`
                      constField "title" "Publications"  `mappend`
                      myCtx y m d hash
   
              makeItem ""
                  >>= loadAndApplyTemplate "templates/pubs.html" archiveCtx
                  >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                  >>= relativizeUrls
   
   
      match (fromList ["index.html", "projects.html"]) $ do
          route idRoute
          compile $ do
              let indexCtx = field "pubs" (const pubList) `mappend`
                      field "soaps" (\_ -> sbIndex $ Just 3)
              getResourceBody
                  >>= applyAsTemplate indexCtx
                  >>= loadAndApplyTemplate "templates/default.html" (articleDateCtx `mappend` myCtx y m d hash)
                  >>= relativizeUrls
   
      match "templates/*" $ compile templateCompiler

      
--------------------------------------------------------------------------------
articleDateCtx :: Context String
articleDateCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

myCtx :: Integer -> Int -> Int -> String -> Context String
myCtx y m d hash =
  field "modified" (\item -> return $ printf "%d/%d/%d" d m y) `mappend` 
  constField "longHash" hash `mappend`
  constField "shortHash" (take 10 hash) `mappend`
  constField "lfmtheme" "Awesome35" `mappend`
  defaultContext

--------------------------------------------------------------------------------
recipesIndex :: Maybe Int -> Compiler String
recipesIndex recent = do
    all     <- loadAll "recipes/*.md" -- recipes
    let pubs = case recent of
                    Nothing -> all
                    Just recent -> take recent all
    itemTpl <- loadBody "templates/recipe-item.html"
    applyTemplateList itemTpl defaultContext (sortBy (compare `on` itemIdentifier) pubs)
    
--------------------------------------------------------------------------------
recipeTags :: [Recipe] -> [String]
recipeTags   []   = []
recipeTags ((R _ ts _):rs) = ts ++ recipeTags rs




------------------------------------------------
recipes :: Compiler [Recipe]
recipes = do
    all <- loadAll "recipes/*.md"
    mapM formatRecipeItem all
      where
        formatRecipeItem :: Item String -> Compiler Recipe
        formatRecipeItem item = do met <- getMetadata (itemIdentifier item)
                                   title <- getMetadataField' (itemIdentifier item) "title"
                                   tags  <- getMetadataField' (itemIdentifier item) "tags"
                                   return (R title (map trim (splitOn "," tags)) (itemBody item))
    
getRecipesForTag tag  = error (show tag)
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
pubList :: Compiler String
pubList = do
    pubs    <- loadAll "pubs/*.md" >>= recentFirst
    itemTpl <- loadBody "templates/pub-item.html"
    applyTemplateList itemTpl articleDateCtx pubs

postList :: Tags -> Pattern -> ([Item String] -> Compiler [Item String]) -> Compiler String
postList tags pattern preprocess' = do
    postItemTpl <- loadBody "templates/recipe-item.html"
    posts <- preprocess' =<< loadAll pattern
    applyTemplateList postItemTpl (tagsCtx tags) posts

tagsCtx :: Tags -> Context String
tagsCtx tags =
  tagsField "prettytags" tags `mappend`
  defaultContext
