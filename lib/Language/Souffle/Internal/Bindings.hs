
module Language.Souffle.Internal.Bindings
  ( Souffle
  , Relation
  , RelationIterator
  , Tuple
  , init
  , free
  , setNumThreads
  , getNumThreads
  , run
  , loadAll
  , printAll
  , getRelation
  , getRelationIterator
  , freeRelationIterator
  , relationIteratorHasNext
  , relationIteratorNext
  , allocTuple
  , freeTuple
  , addTuple
  , tuplePushInt
  , tuplePushString
  , tuplePopInt
  , tuplePopString
  ) where

import Prelude hiding ( init )
import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr


data Souffle
data Relation
data RelationIterator
data Tuple


foreign import ccall unsafe "souffle_init" init
  :: CString -> IO (Ptr Souffle)
foreign import ccall unsafe "&souffle_free" free
  :: FunPtr (Ptr Souffle -> IO ())
foreign import ccall unsafe "souffle_set_num_threads" setNumThreads
  :: Ptr Souffle -> CSize -> IO ()
foreign import ccall unsafe "souffle_get_num_threads" getNumThreads
  :: Ptr Souffle -> IO CSize
foreign import ccall unsafe "souffle_run" run
  :: Ptr Souffle -> IO ()
foreign import ccall unsafe "souffle_load_all" loadAll
  :: Ptr Souffle -> CString -> IO ()
foreign import ccall unsafe "souffle_print_all" printAll
  :: Ptr Souffle -> IO ()
foreign import ccall unsafe "souffle_relation" getRelation
  :: Ptr Souffle -> CString -> IO (Ptr Relation)
foreign import ccall unsafe "souffle_relation_iterator" getRelationIterator
  :: Ptr Relation -> IO (Ptr RelationIterator)
foreign import ccall unsafe "&souffle_relation_iterator_free" freeRelationIterator
  :: FunPtr (Ptr RelationIterator -> IO ())
foreign import ccall unsafe "souffle_relation_iterator_has_next" relationIteratorHasNext
  :: Ptr RelationIterator -> IO CBool
foreign import ccall unsafe "souffle_relation_iterator_next" relationIteratorNext
  :: Ptr RelationIterator -> IO (Ptr Tuple)
foreign import ccall unsafe "souffle_tuple_alloc" allocTuple
  :: Ptr Relation -> IO (Ptr Tuple)
foreign import ccall unsafe "&souffle_tuple_free" freeTuple
  :: FunPtr (Ptr Tuple -> IO ())
foreign import ccall unsafe "souffle_tuple_add" addTuple
  :: Ptr Relation -> Ptr Tuple -> IO ()
foreign import ccall unsafe "souffle_tuple_push_int" tuplePushInt
  :: Ptr Tuple -> CInt -> IO ()
foreign import ccall unsafe "souffle_tuple_push_string" tuplePushString
  :: Ptr Tuple -> CString -> IO ()
foreign import ccall unsafe "souffle_tuple_pop_int" tuplePopInt
  :: Ptr Tuple -> Ptr CInt -> IO ()
foreign import ccall unsafe "souffle_tuple_pop_string" tuplePopString
  :: Ptr Tuple -> Ptr CString -> IO ()

