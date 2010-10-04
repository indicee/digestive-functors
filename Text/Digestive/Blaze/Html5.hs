{-# LANGUAGE OverloadedStrings #-}
module Text.Digestive.Blaze.Html5 where

import Control.Applicative ((<$>))
import Control.Monad (mplus, forM_, unless)
import Data.Maybe (fromMaybe)

import Text.Blaze.Html5 (Html, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import Text.Digestive.Types

inputString :: (Monad m, Functor m)
            => Maybe String
            -> Form m String e Html String
inputString defaultInput = Form $ do
    inp <- fromMaybe "" . (`mplus` defaultInput) <$> getFormInput
    id' <- getFormId
    return (html id' inp, Ok inp)
  where
    html id' inp = View $ const $ H.input ! A.type_ "text"
                                          ! A.name (H.stringValue $ show id')
                                          ! A.id (H.stringValue $ show id')
                                          ! A.value (H.stringValue inp)

prependLabel :: Monad m
             => Html
             -> Form m i e Html a
             -> Form m i e Html a
prependLabel inner = mapViewWithId $ \id' html -> do
    H.label ! A.for (H.stringValue $ show id')
            $ inner
    html

appendErrors :: Monad m
             => Form m i String Html a
             -> Form m i String Html a
appendErrors = mapViewWithErrors $ \errors html -> do
    html
    unless (null errors) $
        H.ul $ forM_ errors $ \e ->
            H.li $ H.string e

appendChildErrors :: Monad m
                  => Form m i String Html a
                  -> Form m i String Html a
appendChildErrors = mapViewWithChildErrors $ \errors html -> do
    html
    unless (null errors) $
        H.ul $ forM_ errors $ \e ->
            H.li $ H.string e
