{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies, ImplicitParams #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Comonad.Trans.Adjoint
-- Copyright   :  (C) 2011 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  MPTCs, fundeps
--
----------------------------------------------------------------------------

module Control.Comonad.Trans.Adjoint
  ( Adjoint
  , runAdjoint
  , adjoint
  , AdjointT(..)
  ) where

import Prelude hiding (sequence)
import Control.Applicative
import Control.Comonad
import Control.Comonad.Trans.Class
import Data.Functor.Adjunction
import Data.Functor.Identity
import Data.Distributive

type Adjoint f g = AdjointT f g Identity

newtype AdjointT f g w a = AdjointT { runAdjointT :: f (w (g a)) }

adjoint :: Functor f => f (g a) -> Adjoint f g a
adjoint = AdjointT . fmap Identity

runAdjoint :: Functor f => Adjoint f g a -> f (g a)
runAdjoint = fmap runIdentity . runAdjointT

instance (Adjunction f g, Functor m) => Functor (AdjointT f g m) where
  fmap f (AdjointT g) = AdjointT $ fmap (fmap (fmap f)) g
  b <$ (AdjointT g) = AdjointT $ fmap (fmap (b <$)) g

instance (Adjunction f g, Comonad m) => Comonad (AdjointT f g m) where
  extract = rightAdjunct extract . runAdjointT
  extend f (AdjointT m) = AdjointT $ fmap (extend $ leftAdjunct (f . AdjointT)) m
  
{-
instance (Adjunction f g, Monad m) => Applicative (AdjointT f g m) where
  pure = AdjointT . leftAdjunct return
  (<*>) = ap
-}
    
instance (Adjunction f g, Distributive g) => ComonadTrans (AdjointT f g) where
  lower = counit . fmap distribute . runAdjointT 