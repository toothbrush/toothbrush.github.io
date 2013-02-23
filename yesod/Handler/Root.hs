module Handler.Root where

import Import

-- This is a handler function for the GET request method on the RootR
-- resource pattern. All of your resource patterns are defined in
-- config/routes
--
-- The majority of the code you will write in Yesod lives in these handler
-- functions. You can spread them across multiple files if you are so
-- inclined, or create a single monolithic file.
getRootR :: Handler RepHtml
getRootR = do
    defaultLayout $ do
        h2id     <- lift newIdent
        tweetDiv <- lift newIdent
        setTitle "denknerd.org"
        addStylesheet  (StaticR css_scrollpath_css)
        addScript (StaticR js_jquery_1_7_2_min_js)
        addScript (StaticR js_date_js)
        addScript (StaticR js_googlefonts_js)
        addScript (StaticR js_lib_jquery_easing_js)
        addScript (StaticR js_jquery_scrollpath_js)
        $(widgetFile "tweets")
        $(widgetFile "homepage")
        addScript (StaticR js_init_scrollpath_js)
