-- File: Main.hs

{-# LANGUAGE Arrows            #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax     #-}

module Main where

import           Hakyll
import           System.FilePath
import           Text.Pandoc (WriterOptions(..))

main ∷ IO ()
main = hakyll $ do
  match ("images/*" .||. "js/*" .||. "favicon.ico" .||. "fonts/*") $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route idRoute
    compile compressCssCompiler

  match "index.html" $ do
    route idRoute
    compile $ getResourceBody
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  match (fromList pages) $ do
    route $ niceRoute ""
    compile $ pandocCompilerWith defaultHakyllReaderOptions woptions
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls
      >>= removeIndexHtml

  -- Read templates
  match "templates/*" $ compile $ templateCompiler

  where
    pages =
      [  "about.md"
      ,  "people.md"
      ,  "services.md"
      ,  "gallery.md"
      ]

niceRoute ∷ String → Routes
niceRoute prefix = customRoute $
                   \ident -> prefix ++ (takeBaseName . toFilePath $ ident) ++ "/index.html"

removeIndexHtml ∷ Item String → Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item
  where
    removeIndexStr ∷ String → String
    removeIndexStr str@(x:xs) | str == "/index.html" = ""
                              | otherwise = x:removeIndexStr xs
    removeIndexStr [] = []

woptions ∷ WriterOptions
woptions = defaultHakyllWriterOptions{ writerSectionDivs = True,
                                       writerStandalone  = True,
                                       writerColumns     = 120,
                                       writerTemplate    = "<div id=\"text2\">About</div>\n<div id=\"text3\">Services</div>\n<div id=\"text4\">Gallery</div>\n<div id=\"text5\">Internal Wiki</div>\n<div id=\"text6\">People</div>\n<div id=\"text7\">Our Motto</div>\n<div id =\"content\">\n$body$\n</div>\n",
                                       writerHtml5       = True
                                     }
