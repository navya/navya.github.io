-- File: Main.hs

{-# LANGUAGE UnicodeSyntax #-}
{-# LANGUAGE Arrows            #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll

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
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls
      
  match (fromList pages) $ do
    route $ setExtension ".html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls
      >>= removeIndexHtml
    -- Read templates
  match "templates/*" $ compile $ templateCompiler
  where
    pages =
      [  "about/index.md"
      ,  "people/index.md"
      ,  "services/index.md"
      ,  "gallery/index.md"]

removeIndexHtml ∷ Item String → Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item
  where
    removeIndexStr ∷ String → String
    removeIndexStr str@(x:xs) | str == "/index.html" = ""
                              | otherwise = x:removeIndexStr xs
    removeIndexStr [] = []
      

      
