
{-# LANGUAGE DeriveGeneric, TypeFamilies, DataKinds, RankNTypes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}
module Test.Language.Souffle.MarshalSpec
  ( module Test.Language.Souffle.MarshalSpec
  ) where

import Test.Hspec
import Test.Hspec.Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import GHC.Generics
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Text
import Data.Int
import Data.Word
import Data.Maybe ( fromJust )
import Control.Monad.IO.Class ( liftIO )
import Language.Souffle.Marshal
import qualified Language.Souffle.Marshal as Souffle
import qualified Language.Souffle.Class as Souffle
import qualified Language.Souffle.Compiled as Compiled
import qualified Language.Souffle.Interpreted as Interpreted
import Data.String (IsString)


data Edge = Edge String String
  deriving (Eq, Show, Generic)

newtype EdgeUInt = EdgeUInt Word32
  deriving (Eq, Show, Generic)

newtype FloatValue = FloatValue Float
  deriving (Eq, Show, Generic)

data EdgeStrict = EdgeStrict !String !String
  deriving (Eq, Show, Generic)

data EdgeUnpacked
  = EdgeUnpacked {-# UNPACK #-} !Int32 {-# UNPACK #-} !Int32
  deriving (Eq, Show, Generic)

type Vertex = Text
type Vertex' = Text

data EdgeSynonyms = EdgeSynonyms Vertex Vertex
  deriving (Eq, Show, Generic)

data EdgeMultipleSynonyms = EdgeMultipleSynonyms Vertex Vertex'
  deriving (Eq, Show, Generic)

data EdgeMixed = EdgeMixed Text Vertex
  deriving (Eq, Show, Generic)

data EdgeRecord
  = EdgeRecord
  { fromNode :: Text
  , toNode :: Text
  } deriving (Eq, Show, Generic)

data IntsAndStrings = IntsAndStrings Text Int32 Text
  deriving (Eq, Show, Generic)

data LargeRecord
  = LargeRecord Int32 Int32 Int32 Int32
  deriving (Eq, Show, Generic)


instance Marshal Edge
instance Marshal EdgeUInt
instance Marshal FloatValue
instance Marshal EdgeStrict
instance Marshal EdgeUnpacked
instance Marshal EdgeSynonyms
instance Marshal EdgeMultipleSynonyms
instance Marshal EdgeMixed
instance Marshal EdgeRecord
instance Marshal IntsAndStrings
instance Marshal LargeRecord


data RoundTrip = RoundTrip

newtype StringFact = StringFact String
  deriving (Eq, Show, Generic)

newtype TextFact = TextFact T.Text
  deriving (Eq, Show, Generic)

newtype LazyTextFact = LazyTextFact TL.Text
  deriving (Eq, Show, Generic)

newtype Int32Fact = Int32Fact Int32
  deriving (Eq, Show, Generic)

newtype Word32Fact = Word32Fact Word32
  deriving (Eq, Show, Generic)

newtype FloatFact = FloatFact Float
  deriving (Eq, Show, Generic)

instance Souffle.Fact StringFact where
  type FactDirection StringFact = 'Souffle.InputOutput
  factName = const "string_fact"

instance Souffle.Fact TextFact where
  type FactDirection TextFact = 'Souffle.InputOutput
  factName = const "string_fact"

instance Souffle.Fact LazyTextFact where
  type FactDirection LazyTextFact = 'Souffle.InputOutput
  factName = const "string_fact"

instance Souffle.Fact Int32Fact where
  type FactDirection Int32Fact = 'Souffle.InputOutput
  factName = const "number_fact"

instance Souffle.Fact Word32Fact where
  type FactDirection Word32Fact = 'Souffle.InputOutput
  factName = const "unsigned_fact"

instance Souffle.Fact FloatFact where
  type FactDirection FloatFact = 'Souffle.InputOutput
  factName = const "float_fact"

instance Souffle.Marshal StringFact
instance Souffle.Marshal TextFact
instance Souffle.Marshal LazyTextFact
instance Souffle.Marshal Int32Fact
instance Souffle.Marshal Word32Fact
instance Souffle.Marshal FloatFact

instance Souffle.Program RoundTrip where
  type ProgramFacts RoundTrip =
    [StringFact, TextFact, LazyTextFact, Int32Fact, Word32Fact, FloatFact]
  programName = const "round_trip"

type RoundTripAction
  = forall a. Souffle.Fact a
  => Souffle.ContainsInputFact RoundTrip a
  => Souffle.ContainsOutputFact RoundTrip a
  => a -> PropertyT IO a


data EdgeCases = EdgeCases

data EmptyStrings a
  = EmptyStrings a a Int32
  deriving (Eq, Show, Generic)

newtype LongStrings a
  = LongStrings a
  deriving (Eq, Show, Generic)

newtype Unicode a
  = Unicode a
  deriving (Eq, Show, Generic)

instance Souffle.Program EdgeCases where
  type ProgramFacts EdgeCases =
    [ EmptyStrings String, EmptyStrings T.Text, EmptyStrings TL.Text
    , LongStrings String, LongStrings T.Text, LongStrings TL.Text
    , Unicode String, Unicode T.Text, Unicode TL.Text
    ]
  programName = const "edge_cases"

instance Souffle.Fact (EmptyStrings String) where
  type FactDirection (EmptyStrings String) = 'Souffle.InputOutput
  factName = const "empty_strings"
instance Souffle.Fact (EmptyStrings T.Text) where
  type FactDirection (EmptyStrings T.Text) = 'Souffle.InputOutput
  factName = const "empty_strings"
instance Souffle.Fact (EmptyStrings TL.Text) where
  type FactDirection (EmptyStrings TL.Text) = 'Souffle.InputOutput
  factName = const "empty_strings"

instance Souffle.Fact (LongStrings String) where
  type FactDirection (LongStrings String) = 'Souffle.InputOutput
  factName = const "long_strings"
instance Souffle.Fact (LongStrings T.Text) where
  type FactDirection (LongStrings T.Text) = 'Souffle.InputOutput
  factName = const "long_strings"
instance Souffle.Fact (LongStrings TL.Text) where
  type FactDirection (LongStrings TL.Text) = 'Souffle.InputOutput
  factName = const "long_strings"

instance Souffle.Fact (Unicode String) where
  type FactDirection (Unicode String) = 'Souffle.InputOutput
  factName = const "unicode"
instance Souffle.Fact (Unicode T.Text) where
  type FactDirection (Unicode T.Text) = 'Souffle.InputOutput
  factName = const "unicode"
instance Souffle.Fact (Unicode TL.Text) where
  type FactDirection (Unicode TL.Text) = 'Souffle.InputOutput
  factName = const "unicode"

instance Marshal (EmptyStrings String)
instance Marshal (EmptyStrings T.Text)
instance Marshal (EmptyStrings TL.Text)
instance Marshal (LongStrings String)
instance Marshal (LongStrings T.Text)
instance Marshal (LongStrings TL.Text)
instance Marshal (Unicode String)
instance Marshal (Unicode T.Text)
instance Marshal (Unicode TL.Text)


spec :: Spec
spec = describe "Marshalling" $ parallel $ do
  describe "Auto-deriving marshalling code" $
    it "can generate code for all instances in this file" $
      -- If this file compiles, then the test has already passed
      42 `shouldBe` 42

  describe "data transfer between Haskell and Souffle" $ parallel $ do
    let roundTripTests :: RoundTripAction -> Spec
        roundTripTests run = do
          it "can serialize and deserialize String values" $ hedgehog $ do
            str <- forAll $ Gen.string (Range.linear 0 10) Gen.unicode
            let fact = StringFact str
            fact' <- run fact
            fact === fact'

          it "can serialize and deserialize lazy Text" $ hedgehog $ do
            str <- forAll $ Gen.string (Range.linear 0 10) Gen.unicode
            let fact = LazyTextFact (TL.pack str)
            fact' <- run fact
            fact === fact'

          it "can serialize and deserialize strict Text values" $ hedgehog $ do
            str <- forAll $ Gen.text (Range.linear 0 10) Gen.unicode
            let fact = TextFact str
            fact' <- run fact
            fact === fact'

          it "can serialize and deserialize Int32 values" $ hedgehog $ do
            x <- forAll $ Gen.int32 (Range.linear minBound maxBound)
            let fact = Int32Fact x
            fact' <- run fact
            fact === fact'

          it "can serialize and deserialize Word32 values" $ hedgehog $ do
            x <- forAll $ Gen.word32 (Range.linear minBound maxBound)
            let fact = Word32Fact x
            fact' <- run fact
            fact === fact'

          it "can serialize and deserialize Float values" $ hedgehog $ do
            let epsilon = 1e-6
                fmin = -1e9
                fmax =  1e9
            x <- forAll $ Gen.float (Range.exponentialFloat fmin fmax)
            let fact = FloatFact x
            FloatFact x' <- run fact
            (abs (x' - x) < epsilon) === True

    describe "interpreted mode" $ parallel $
      roundTripTests $ \fact -> liftIO $ Interpreted.runSouffle RoundTrip $ \handle -> do
        let prog = fromJust handle
        Interpreted.addFact prog fact
        Interpreted.run prog
        Prelude.head <$> Interpreted.getFacts prog

    describe "compiled mode" $ parallel $
      roundTripTests $ \fact -> liftIO $ Compiled.runSouffle RoundTrip $ \handle -> do
        let prog = fromJust handle
        Compiled.addFact prog fact
        Compiled.run prog
        Prelude.head <$> Compiled.getFacts prog

  describe "edge cases" $ parallel $ do
    let longString :: IsString a => a
        longString = "long_string_from_DL:...............................................................................................................................................................................................................................................................................................end"

    -- TODO both for interpreted and compiled mode
    it "correctly marshals facts with empty Strings" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [EmptyStrings String])
        `shouldBe` [ EmptyStrings "" "" 42
                   , EmptyStrings "" "abc" 42
                   , EmptyStrings "abc" "" 42
                   ]

    it "correctly marshals facts with empty Texts" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [EmptyStrings T.Text])
        `shouldBe` [ EmptyStrings "" "" 42
                   , EmptyStrings "" "abc" 42
                   , EmptyStrings "abc" "" 42
                   ]

    it "correctly marshals facts with empty lazy Texts" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [EmptyStrings TL.Text])
        `shouldBe` [ EmptyStrings "" "" 42
                   , EmptyStrings "" "abc" 42
                   , EmptyStrings "abc" "" 42
                   ]

    -- TODO write to datalog and back

    it "correctly marshals facts really with long (>255 chars) String" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [LongStrings String]) `shouldBe` [ LongStrings longString ]

    it "correctly marshals facts really with long (>255 chars) Text" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [LongStrings T.Text]) `shouldBe` [ LongStrings longString ]

    it "correctly marshals facts really with long (>255 chars) lazy Text" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [LongStrings TL.Text]) `shouldBe` [ LongStrings longString ]

    -- TODO marshal back and forth

    -- TODO 1 in a row, 2 in a row, unicode chars with 1 byte the same
    -- TODO: findFact + getFacts
    it "correctly marshals facts containing unicode characters (String)" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [Unicode String]) `shouldBe`
        [ Unicode "∀", Unicode "∀∀" ]

    it "correctly marshals facts containing unicode characters (Text)" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [Unicode T.Text]) `shouldBe`
        [ Unicode "∀", Unicode "∀∀" ]

    it "correctly marshals facts containing unicode characters (lazy Text)" $ do
      facts <- Interpreted.runSouffle EdgeCases $ \handle -> do
        let prog = fromJust handle
        Interpreted.run prog
        Interpreted.getFacts prog
      (facts :: [Unicode TL.Text]) `shouldBe`
        [ Unicode "∀", Unicode "∀∀" ]

    -- TODO check overlap with some unicode chars
