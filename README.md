## Generating the site

This is a Hakyll/Pandoc site, the easiest way to get something working is this:

'''sh
  cabal install hakyll
  cd $thisRepo
  ghc --make site.hs
  ./site preview
'''

Now you can see a local preview of the site by visiting `localhost:8000`.
