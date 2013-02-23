--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Control.Applicative ((<$>))
import           Data.Monoid         (mappend)
import           Hakyll
import Text.Printf
import Data.Time.Clock
import Data.Time.Calendar

--------------------------------------------------------------------------------
main :: IO ()
main =
 do (y,m,d) <- getCurrentTime >>= return . toGregorian . utctDay


    hakyll $ do

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "pdf/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "pubs/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/pub.html"    (pubCtx `mappend` myCtx y m d)
            >>= loadAndApplyTemplate "templates/default.html" (pubCtx `mappend` myCtx y m d)
            >>= relativizeUrls

    create ["pubs.html"] $ do
        route idRoute
        compile $ do
            let archiveCtx =
                    field "pubs" (\_ -> pubList recentFirst) `mappend`
                    constField "title" "Publications"              `mappend`
                    myCtx y m d

            makeItem ""
                >>= loadAndApplyTemplate "templates/pubs.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match (fromList ["index.html", "projects.html"]) $ do
        route idRoute
        compile $ do
            let indexCtx = field "pubs" $ \_ -> pubList (take 3 . recentFirst)

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" (pubCtx `mappend` myCtx y m d)
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
pubCtx :: Context String
pubCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

myCtx :: Integer -> Int -> Int -> Context String
myCtx y m d = field "modified" (\item -> return $ printf "%d/%d/%d" d m y) `mappend` defaultContext

--------------------------------------------------------------------------------
pubList :: ([Item String] -> [Item String]) -> Compiler String
pubList sortFilter = do
    pubs   <- sortFilter <$> loadAll "pubs/*"
    itemTpl <- loadBody "templates/pub-item.html"
    list    <- applyTemplateList itemTpl pubCtx pubs
    return list
