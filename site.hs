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
import Data.List (sortBy)
import Git
import Git.Libgit2
import Data.ByteString (ByteString)
import Data.Maybe
import Data.Text.Encoding (encodeUtf8)
import qualified Data.Text as T
import System.Directory
import Filesystem.Path.CurrentOS

--------------------------------------------------------------------------------
main :: IO ()
main =
 do (y,m,d) <- liftM (toGregorian . utctDay) getCurrentTime 

    path <- getCurrentDirectory
    let repoOpts = RepositoryOptions { repoPath = path
                                     , repoWorkingDir = Nothing
                                     , repoIsBare = False
                                     , repoAutoCreate = False
                                     }
    repo <- liftIO $ openLgRepository repoOpts
    commitFromRef <- liftIO $ runStderrLoggingT $ runLgRepository repo action
    putStrLn $ "commit = " ++ show commitFromRef
    let hash = show commitFromRef

    hakyll $ do

       match "images/*" $ do
           route   idRoute
           compile copyFileCompiler
   
       match "css/*.css" $ do
           route   idRoute
           compile compressCssCompiler
   
       match "bib/*" $ do
           route   idRoute
           compile copyFileCompiler
   
       match "pdf/*" $ do
           route   idRoute
           compile copyFileCompiler
   
       match "recipes/*.md" $ do
           route $ setExtension "html"
           compile $ do
                   let sbCtx = 
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
   
       create ["recipes/index.html", "recipes-index.html"] $ do
           route idRoute
           compile $ do
               let archiveCtx =
                       field "recipes" (\_ -> recipesIndex Nothing) `mappend`
                       constField "title" "Recipes"  `mappend`
                       myCtx y m d hash
               makeItem ""
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

  where
    action = do
      let masterRef = "refs/heads/master"
      Just cParent <- resolveReference masterRef
      return cParent
      
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
    all     <- loadAll "recipes/*.md" >>= recentFirst
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
pubList :: Compiler String
pubList = do
    pubs    <- loadAll "pubs/*.md" >>= recentFirst
    itemTpl <- loadBody "templates/pub-item.html"
    applyTemplateList itemTpl articleDateCtx pubs
