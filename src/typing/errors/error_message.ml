(**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open Type
open Reason
open Utils_js

exception EDebugThrow of ALoc.t

exception EMergeTimeout of float

exception ECheckTimeout of float

type invalid_char_set =
  | DuplicateChar of Char.t
  | InvalidChar of Char.t

module InvalidCharSetSet = Set.Make (struct
  type t = invalid_char_set

  let compare = Pervasives.compare
end)

type t = ALoc.t t'

and 'loc t' =
  | EIncompatible of {
      lower: 'loc virtual_reason * lower_kind option;
      upper: 'loc virtual_reason * 'loc upper_kind;
      use_op: 'loc virtual_use_op option;
      branches: ('loc Reason.virtual_reason * t) list;
    }
  | EIncompatibleDefs of {
      use_op: 'loc virtual_use_op;
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      branches: ('loc Reason.virtual_reason * t) list;
    }
  | EIncompatibleProp of {
      prop: string option;
      reason_prop: 'loc virtual_reason;
      reason_obj: 'loc virtual_reason;
      special: lower_kind option;
      use_op: 'loc virtual_use_op option;
    }
  | EDebugPrint of 'loc virtual_reason * string
  | EExportValueAsType of 'loc virtual_reason * string
  | EImportValueAsType of 'loc virtual_reason * string
  | EImportTypeAsTypeof of 'loc virtual_reason * string
  | EImportTypeAsValue of 'loc virtual_reason * string
  | ERefineAsValue of 'loc virtual_reason * string
  | ENoDefaultExport of 'loc virtual_reason * string * string option
  | EOnlyDefaultExport of 'loc virtual_reason * string * string
  | ENoNamedExport of 'loc virtual_reason * string * string * string option
  | EMissingTypeArgs of {
      reason_tapp: 'loc virtual_reason;
      reason_arity: 'loc virtual_reason;
      min_arity: int;
      max_arity: int;
    }
  | EValueUsedAsType of { reason_use: 'loc virtual_reason }
  | EExpectedStringLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExpectedNumberLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExpectedBooleanLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EPropNotFound of
      string option * ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | EPropNotReadable of {
      reason_prop: 'loc virtual_reason;
      prop_name: string option;
      use_op: 'loc virtual_use_op;
    }
  | EPropNotWritable of {
      reason_prop: 'loc virtual_reason;
      prop_name: string option;
      use_op: 'loc virtual_use_op;
    }
  | EPropPolarityMismatch of
      ('loc virtual_reason * 'loc virtual_reason)
      * string option
      * (Polarity.t * Polarity.t)
      * 'loc virtual_use_op
  | EPolarityMismatch of {
      reason: 'loc virtual_reason;
      name: string;
      expected_polarity: Polarity.t;
      actual_polarity: Polarity.t;
    }
  | EBuiltinLookupFailed of {
      reason: 'loc virtual_reason;
      name: string option;
    }
  | EStrictLookupFailed of {
      reason_prop: 'loc virtual_reason;
      reason_obj: 'loc virtual_reason;
      name: string option;
      use_op: 'loc virtual_use_op option;
    }
  | EPrivateLookupFailed of
      ('loc virtual_reason * 'loc virtual_reason) * string * 'loc virtual_use_op
  | EAdditionMixed of 'loc virtual_reason * 'loc virtual_use_op
  | EComparison of ('loc virtual_reason * 'loc virtual_reason)
  | ETupleArityMismatch of
      ('loc virtual_reason * 'loc virtual_reason) * int * int * 'loc virtual_use_op
  | ENonLitArrayToTuple of ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | ETupleOutOfBounds of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      length: int;
      index: string;
    }
  | ETupleNonIntegerIndex of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      index: string;
    }
  | ETupleUnsafeWrite of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EROArrayWrite of ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | EUnionSpeculationFailed of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      branches: ('loc virtual_reason * t) list;
    }
  | ESpeculationAmbiguous of {
      reason: 'loc virtual_reason;
      prev_case: int * 'loc virtual_reason;
      case: int * 'loc virtual_reason;
      cases: 'loc virtual_reason list;
    }
  | EIncompatibleWithExact of ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | EUnsupportedExact of ('loc virtual_reason * 'loc virtual_reason)
  | EIdxArity of 'loc virtual_reason
  | EIdxUse1 of 'loc virtual_reason
  | EIdxUse2 of 'loc virtual_reason
  | EUnexpectedThisType of 'loc
  | ETypeParamArity of 'loc * int
  | ECallTypeArity of {
      call_loc: 'loc;
      is_new: bool;
      reason_arity: 'loc virtual_reason;
      expected_arity: int;
    }
  | ETypeParamMinArity of 'loc * int
  | ETooManyTypeArgs of 'loc virtual_reason * 'loc virtual_reason * int
  | ETooFewTypeArgs of 'loc virtual_reason * 'loc virtual_reason * int
  | EInvalidTypeArgs of 'loc virtual_reason * 'loc virtual_reason
  | EPropertyTypeAnnot of 'loc
  | EExportsAnnot of 'loc
  | ECharSetAnnot of 'loc
  | EInvalidCharSet of {
      invalid: 'loc virtual_reason * InvalidCharSetSet.t;
      valid: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EUnsupportedKeyInObjectType of 'loc
  | EPredAnnot of 'loc
  | ERefineAnnot of 'loc
  | ETrustedAnnot of 'loc
  | EPrivateAnnot of 'loc
  | EUnexpectedTypeof of 'loc
  | EFunPredCustom of ('loc virtual_reason * 'loc virtual_reason) * string
  | EIncompatibleWithShape of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | EInternal of 'loc * internal_error
  | EUnsupportedSyntax of 'loc * unsupported_syntax
  | EUseArrayLiteral of 'loc
  | EMissingAnnotation of 'loc virtual_reason * 'loc virtual_reason list
  | EBindingError of binding_error * 'loc * string * Scope.Entry.t
  | ERecursionLimit of ('loc virtual_reason * 'loc virtual_reason)
  | EModuleOutsideRoot of 'loc * string
  | EMalformedPackageJson of 'loc * string
  | EExperimentalClassProperties of 'loc * bool
  | EUninitializedInstanceProperty of 'loc * Lints.property_assignment_kind
  | EExperimentalDecorators of 'loc
  | EExperimentalExportStarAs of 'loc
  | EExperimentalEnums of 'loc
  | EUnsafeGetSet of 'loc
  | EIndeterminateModuleType of 'loc
  | EBadExportPosition of 'loc
  | EBadExportContext of string * 'loc
  | EUnreachable of 'loc
  | EInvalidObjectKit of {
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidTypeof of 'loc * string
  | EBinaryInLHS of 'loc virtual_reason
  | EBinaryInRHS of 'loc virtual_reason
  | EArithmeticOperand of 'loc virtual_reason
  | EForInRHS of 'loc virtual_reason
  | EObjectComputedPropertyAccess of ('loc virtual_reason * 'loc virtual_reason)
  | EObjectComputedPropertyAssign of ('loc virtual_reason * 'loc virtual_reason)
  | EInvalidLHSInAssignment of 'loc
  | EIncompatibleWithUseOp of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | ETrustIncompatibleWithUseOp of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | EUnsupportedImplements of 'loc virtual_reason
  | ENotAReactComponent of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidReactConfigType of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidReactPropType of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
      tool: React.SimplifyPropType.tool;
    }
  | EInvalidReactCreateClass of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
      tool: React.CreateClass.tool;
    }
  | EReactElementFunArity of 'loc virtual_reason * string * int
  | EFunctionCallExtraArg of 'loc virtual_reason * 'loc virtual_reason * int * 'loc virtual_use_op
  | EUnsupportedSetProto of 'loc virtual_reason
  | EDuplicateModuleProvider of {
      module_name: string;
      provider: 'loc;
      conflict: 'loc;
    }
  | EParseError of 'loc * Parse_error.t
  | EDocblockError of 'loc * docblock_error
  | EImplicitInexactObject of 'loc
  (* The string is either the name of a module or "the module that exports `_`". *)
  | EUntypedTypeImport of 'loc * string
  | EUntypedImport of 'loc * string
  | ENonstrictImport of 'loc
  | EUnclearType of 'loc
  | EDeprecatedType of 'loc
  | EDeprecatedUtility of 'loc * string
  | EDynamicExport of 'loc virtual_reason * 'loc virtual_reason
  | EUnsafeGettersSetters of 'loc
  | EUnusedSuppression of 'loc
  | ELintSetting of 'loc * LintSettings.lint_parse_error
  | ESketchyNullLint of {
      kind: Lints.sketchy_null_kind;
      loc: 'loc;
      null_loc: 'loc;
      falsy_loc: 'loc;
    }
  | ESketchyNumberLint of Lints.sketchy_number_kind * 'loc virtual_reason
  | EInvalidPrototype of 'loc virtual_reason
  | EExperimentalOptionalChaining of 'loc
  | EOptionalChainingMethods of 'loc
  | EUnnecessaryOptionalChain of 'loc * 'loc virtual_reason
  | EUnnecessaryInvariant of 'loc * 'loc virtual_reason
  | EInexactSpread of 'loc virtual_reason * 'loc virtual_reason
  | EUnexpectedTemporaryBaseType of 'loc
  | ECannotDelete of 'loc * 'loc virtual_reason
  | EBigIntNotYetSupported of 'loc virtual_reason
  | ESignatureVerification of 'loc Signature_error.t
  | ENonArraySpread of 'loc virtual_reason
  | ECannotSpreadInterface of {
      spread_reason: 'loc virtual_reason;
      interface_reason: 'loc virtual_reason;
    }
  | ECannotSpreadIndexerOnRight of {
      spread_reason: 'loc virtual_reason;
      object_reason: 'loc virtual_reason;
      key_reason: 'loc virtual_reason;
    }
  | EUnableToSpread of {
      spread_reason: 'loc virtual_reason;
      object1_reason: 'loc virtual_reason;
      object2_reason: 'loc virtual_reason;
      propname: string;
      error_kind: spread_error_kind;
    }
  | EInexactMayOverwriteIndexer of {
      spread_reason: 'loc virtual_reason;
      key_reason: 'loc virtual_reason;
      value_reason: 'loc virtual_reason;
      object2_reason: 'loc virtual_reason;
    }
  | EExponentialSpread of {
      reason: 'loc virtual_reason;
      reasons_for_operand1: 'loc virtual_reason Nel.t;
      reasons_for_operand2: 'loc virtual_reason Nel.t;
    }
  | EComputedPropertyWithMultipleLowerBounds of {
      computed_property_reason: 'loc virtual_reason;
      new_lower_bound_reason: 'loc virtual_reason;
      existing_lower_bound_reason: 'loc virtual_reason;
    }
  | EComputedPropertyWithUnion of {
      computed_property_reason: 'loc virtual_reason;
      union_reason: 'loc virtual_reason;
    }

and spread_error_kind =
  | Indexer
  | Inexact

and binding_error =
  | ENameAlreadyBound
  | EReferencedBeforeDeclaration
  | ETypeInValuePosition
  | ETypeAliasInValuePosition
  | EConstReassigned
  | EConstParamReassigned
  | EImportReassigned
  | EEnumReassigned

and docblock_error =
  | MultipleFlowAttributes
  | MultipleProvidesModuleAttributes
  | MultipleJSXAttributes
  | InvalidJSXAttribute of string option

and internal_error =
  | PackageHeapNotFound of string
  | AbnormalControlFlow
  | MethodNotAFunction
  | OptionalMethod
  | OpenPredWithoutSubst
  | PredFunWithoutParamNames
  | UnsupportedGuardPredicate of string
  | BreakEnvMissingForCase
  | PropertyDescriptorPropertyCannotBeRead
  | ForInLHS
  | ForOfLHS
  | InstanceLookupComputed
  | PropRefComputedOpen
  | PropRefComputedLiteral
  | ShadowReadComputed
  | ShadowWriteComputed
  | RestParameterNotIdentifierPattern
  | InterfaceTypeSpread
  | DebugThrow
  | MergeTimeout of float
  | MergeJobException of Exception.t
  | CheckTimeout of float
  | CheckJobException of Exception.t
  | UnexpectedTypeapp of string

and unsupported_syntax =
  | ComprehensionExpression
  | GeneratorExpression
  | MetaPropertyExpression
  | ObjectPropertyLiteralNonString
  | ObjectPropertyGetSet
  | ObjectPropertyComputedGetSet
  | InvariantSpreadArgument
  | ClassPropertyLiteral
  | ClassPropertyComputed
  | ReactCreateClassPropertyNonInit
  | RequireDynamicArgument
  | RequireLazyDynamicArgument
  | CatchParameterAnnotation
  | CatchParameterDeclaration
  | DestructuringObjectPropertyLiteralNonString
  | DestructuringExpressionPattern
  | PredicateDeclarationForImplementation
  | PredicateDeclarationWithoutExpression
  | PredicateDeclarationAnonymousParameters
  | PredicateInvalidBody
  | PredicateFunctionAbstractReturnType
  | PredicateVoidReturn
  | MultipleIndexers
  | MultipleProtos
  | ExplicitCallAfterProto
  | ExplicitProtoAfterCall
  | SpreadArgument
  | ImportDynamicArgument
  | IllegalName
  | UnsupportedInternalSlot of {
      name: string;
      static: bool;
    }

and lower_kind =
  | Possibly_null
  | Possibly_void
  | Possibly_null_or_void
  | Incompatible_intersection

and 'loc upper_kind =
  | IncompatibleGetPropT of 'loc * string option
  | IncompatibleSetPropT of 'loc * string option
  | IncompatibleMatchPropT of 'loc * string option
  | IncompatibleGetPrivatePropT
  | IncompatibleSetPrivatePropT
  | IncompatibleMethodT of 'loc * string option
  | IncompatibleCallT
  | IncompatibleMixedCallT
  | IncompatibleConstructorT
  | IncompatibleGetElemT of 'loc
  | IncompatibleSetElemT of 'loc
  | IncompatibleCallElemT of 'loc
  | IncompatibleElemTOfArrT
  | IncompatibleObjAssignFromTSpread
  | IncompatibleObjAssignFromT
  | IncompatibleObjRestT
  | IncompatibleObjSealT
  | IncompatibleArrRestT
  | IncompatibleSuperT
  | IncompatibleMixinT
  | IncompatibleSpecializeT
  | IncompatibleThisSpecializeT
  | IncompatibleVarianceCheckT
  | IncompatibleGetKeysT
  | IncompatibleHasOwnPropT of 'loc * string option
  | IncompatibleGetValuesT
  | IncompatibleUnaryMinusT
  | IncompatibleMapTypeTObject
  | IncompatibleTypeAppVarianceCheckT
  | IncompatibleGetStaticsT
  | IncompatibleUnclassified of string

let map_loc_of_error_message (f : 'a -> 'b) : 'a t' -> 'b t' =
  let map_use_op = TypeUtil.mod_loc_of_virtual_use_op f in
  let map_reason = Reason.map_reason_locs f in
  let map_branch (r, e) = (map_reason r, e) in
  let map_upper_kind = function
    | IncompatibleGetPropT (loc, s) -> IncompatibleGetPropT (f loc, s)
    | IncompatibleSetPropT (loc, s) -> IncompatibleSetPropT (f loc, s)
    | IncompatibleMatchPropT (loc, s) -> IncompatibleMatchPropT (f loc, s)
    | IncompatibleMethodT (loc, s) -> IncompatibleMethodT (f loc, s)
    | IncompatibleHasOwnPropT (loc, s) -> IncompatibleHasOwnPropT (f loc, s)
    | IncompatibleGetElemT loc -> IncompatibleGetElemT (f loc)
    | IncompatibleSetElemT loc -> IncompatibleSetElemT (f loc)
    | IncompatibleCallElemT loc -> IncompatibleCallElemT (f loc)
    | ( IncompatibleGetPrivatePropT | IncompatibleSetPrivatePropT | IncompatibleCallT
      | IncompatibleMixedCallT | IncompatibleConstructorT | IncompatibleElemTOfArrT
      | IncompatibleObjAssignFromTSpread | IncompatibleObjAssignFromT | IncompatibleObjRestT
      | IncompatibleObjSealT | IncompatibleArrRestT | IncompatibleSuperT | IncompatibleMixinT
      | IncompatibleSpecializeT | IncompatibleThisSpecializeT | IncompatibleVarianceCheckT
      | IncompatibleGetKeysT | IncompatibleGetValuesT | IncompatibleUnaryMinusT
      | IncompatibleMapTypeTObject | IncompatibleTypeAppVarianceCheckT | IncompatibleGetStaticsT
      | IncompatibleUnclassified _ ) as u ->
      u
  in
  function
  | EIncompatible { use_op; lower = (lreason, lkind); upper = (ureason, ukind); branches } ->
    EIncompatible
      {
        use_op = Option.map ~f:map_use_op use_op;
        lower = (map_reason lreason, lkind);
        upper = (map_reason ureason, map_upper_kind ukind);
        branches = Core_list.map ~f:map_branch branches;
      }
  | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
    EIncompatibleDefs
      {
        use_op = map_use_op use_op;
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        branches = Core_list.map ~f:map_branch branches;
      }
  | EIncompatibleProp { use_op; prop; reason_prop; reason_obj; special } ->
    EIncompatibleProp
      {
        use_op = Option.map ~f:map_use_op use_op;
        prop;
        reason_prop = map_reason reason_prop;
        reason_obj = map_reason reason_obj;
        special;
      }
  | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
    EExpectedStringLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
    EExpectedNumberLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
    EExpectedBooleanLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EPropNotFound (prop, (r1, r2), op) ->
    EPropNotFound (prop, (map_reason r1, map_reason r2), map_use_op op)
  | EPropNotReadable { reason_prop; prop_name; use_op } ->
    EPropNotReadable
      { reason_prop = map_reason reason_prop; prop_name; use_op = map_use_op use_op }
  | EPropNotWritable { reason_prop; prop_name; use_op } ->
    EPropNotWritable
      { reason_prop = map_reason reason_prop; prop_name; use_op = map_use_op use_op }
  | EPropPolarityMismatch ((r1, r2), p, ps, op) ->
    EPropPolarityMismatch ((map_reason r1, map_reason r2), p, ps, map_use_op op)
  | EBuiltinLookupFailed { reason; name } ->
    EBuiltinLookupFailed { reason = map_reason reason; name }
  | EStrictLookupFailed { reason_prop; reason_obj; name; use_op } ->
    EStrictLookupFailed
      {
        reason_prop = map_reason reason_prop;
        reason_obj = map_reason reason_obj;
        name;
        use_op = Option.map ~f:map_use_op use_op;
      }
  | EPrivateLookupFailed ((r1, r2), x, op) ->
    EPrivateLookupFailed ((map_reason r1, map_reason r2), x, map_use_op op)
  | EAdditionMixed (r, op) -> EAdditionMixed (map_reason r, map_use_op op)
  | ETupleArityMismatch ((r1, r2), l, i, op) ->
    ETupleArityMismatch ((map_reason r1, map_reason r2), l, i, map_use_op op)
  | ENonLitArrayToTuple ((r1, r2), op) ->
    ENonLitArrayToTuple ((map_reason r1, map_reason r2), map_use_op op)
  | ETupleOutOfBounds { use_op; reason; reason_op; length; index } ->
    ETupleOutOfBounds
      {
        use_op = map_use_op use_op;
        reason = map_reason reason;
        reason_op = map_reason reason_op;
        length;
        index;
      }
  | ETupleNonIntegerIndex { use_op; reason; index } ->
    ETupleNonIntegerIndex { use_op = map_use_op use_op; reason = map_reason reason; index }
  | ETupleUnsafeWrite { reason; use_op } ->
    ETupleUnsafeWrite { reason = map_reason reason; use_op = map_use_op use_op }
  | EROArrayWrite ((r1, r2), op) -> EROArrayWrite ((map_reason r1, map_reason r2), map_use_op op)
  | EUnionSpeculationFailed { use_op; reason; reason_op; branches } ->
    EUnionSpeculationFailed
      {
        use_op = map_use_op use_op;
        reason = map_reason reason;
        reason_op = map_reason reason_op;
        branches = Core_list.map ~f:map_branch branches;
      }
  | EIncompatibleWithExact ((r1, r2), op) ->
    EIncompatibleWithExact ((map_reason r1, map_reason r2), map_use_op op)
  | EInvalidCharSet { invalid = (ir, set); valid; use_op } ->
    EInvalidCharSet
      { invalid = (map_reason ir, set); valid = map_reason valid; use_op = map_use_op use_op }
  | EIncompatibleWithShape (l, u, use_op) ->
    EIncompatibleWithShape (map_reason l, map_reason u, map_use_op use_op)
  | EInvalidObjectKit { reason; reason_op; use_op } ->
    EInvalidObjectKit
      { reason = map_reason reason; reason_op = map_reason reason_op; use_op = map_use_op use_op }
  | EIncompatibleWithUseOp (rl, ru, op) ->
    EIncompatibleWithUseOp (map_reason rl, map_reason ru, map_use_op op)
  | ETrustIncompatibleWithUseOp (rl, ru, op) ->
    ETrustIncompatibleWithUseOp (map_reason rl, map_reason ru, map_use_op op)
  | ENotAReactComponent { reason; use_op } ->
    ENotAReactComponent { reason = map_reason reason; use_op = map_use_op use_op }
  | EInvalidReactConfigType { reason; use_op } ->
    EInvalidReactConfigType { reason = map_reason reason; use_op = map_use_op use_op }
  | EInvalidReactPropType { reason; use_op; tool } ->
    EInvalidReactPropType { reason = map_reason reason; use_op = map_use_op use_op; tool }
  | EInvalidReactCreateClass { reason; use_op; tool } ->
    EInvalidReactCreateClass { reason = map_reason reason; use_op = map_use_op use_op; tool }
  | EFunctionCallExtraArg (rl, ru, n, op) ->
    EFunctionCallExtraArg (map_reason rl, map_reason ru, n, map_use_op op)
  | EDebugPrint (r, s) -> EDebugPrint (map_reason r, s)
  | EExportValueAsType (r, s) -> EExportValueAsType (map_reason r, s)
  | EImportValueAsType (r, s) -> EImportValueAsType (map_reason r, s)
  | EImportTypeAsTypeof (r, s) -> EImportTypeAsTypeof (map_reason r, s)
  | EImportTypeAsValue (r, s) -> EImportTypeAsValue (map_reason r, s)
  | ERefineAsValue (r, s) -> ERefineAsValue (map_reason r, s)
  | ENoDefaultExport (r, s1, s2) -> ENoDefaultExport (map_reason r, s1, s2)
  | EOnlyDefaultExport (r, s1, s2) -> EOnlyDefaultExport (map_reason r, s1, s2)
  | ENoNamedExport (r, s1, s2, s3) -> ENoNamedExport (map_reason r, s1, s2, s3)
  | EMissingTypeArgs { reason_tapp; reason_arity; min_arity; max_arity } ->
    EMissingTypeArgs
      {
        reason_tapp = map_reason reason_tapp;
        reason_arity = map_reason reason_arity;
        min_arity;
        max_arity;
      }
  | EValueUsedAsType { reason_use } -> EValueUsedAsType { reason_use = map_reason reason_use }
  | EPolarityMismatch { reason; name; expected_polarity; actual_polarity } ->
    EPolarityMismatch { reason = map_reason reason; name; expected_polarity; actual_polarity }
  | EComparison (r1, r2) -> EComparison (map_reason r1, map_reason r2)
  | ESpeculationAmbiguous
      { reason; prev_case = (prev_i, prev_case_reason); case = (i, case_reason); cases } ->
    ESpeculationAmbiguous
      {
        reason = map_reason reason;
        prev_case = (prev_i, map_reason prev_case_reason);
        case = (i, map_reason case_reason);
        cases = Core_list.map ~f:map_reason cases;
      }
  | EUnsupportedExact (r1, r2) -> EUnsupportedExact (map_reason r1, map_reason r2)
  | EIdxArity r -> EIdxArity (map_reason r)
  | EIdxUse1 r -> EIdxUse1 (map_reason r)
  | EIdxUse2 r -> EIdxUse2 (map_reason r)
  | EUnexpectedThisType loc -> EUnexpectedThisType (f loc)
  | ETypeParamArity (loc, i) -> ETypeParamArity (f loc, i)
  | ECallTypeArity { call_loc; is_new; reason_arity; expected_arity } ->
    ECallTypeArity
      { call_loc = f call_loc; is_new; expected_arity; reason_arity = map_reason reason_arity }
  | ETypeParamMinArity (loc, i) -> ETypeParamMinArity (f loc, i)
  | ETooManyTypeArgs (r1, r2, i) -> ETooManyTypeArgs (map_reason r1, map_reason r2, i)
  | ETooFewTypeArgs (r1, r2, i) -> ETooFewTypeArgs (map_reason r1, map_reason r2, i)
  | EInvalidTypeArgs (r1, r2) -> EInvalidTypeArgs (map_reason r1, map_reason r2)
  | EPropertyTypeAnnot loc -> EPropertyTypeAnnot (f loc)
  | EExportsAnnot loc -> EExportsAnnot (f loc)
  | ECharSetAnnot loc -> ECharSetAnnot (f loc)
  | EUnsupportedKeyInObjectType loc -> EUnsupportedKeyInObjectType (f loc)
  | EPredAnnot loc -> EPredAnnot (f loc)
  | ERefineAnnot loc -> ERefineAnnot (f loc)
  | ETrustedAnnot loc -> ETrustedAnnot (f loc)
  | EPrivateAnnot loc -> EPrivateAnnot (f loc)
  | EUnexpectedTypeof loc -> EUnexpectedTypeof (f loc)
  | EFunPredCustom ((r1, r2), s) -> EFunPredCustom ((map_reason r1, map_reason r2), s)
  | EInternal (loc, i) -> EInternal (f loc, i)
  | EUnsupportedSyntax (loc, u) -> EUnsupportedSyntax (f loc, u)
  | EUseArrayLiteral loc -> EUseArrayLiteral (f loc)
  | EMissingAnnotation (r, rs) -> EMissingAnnotation (map_reason r, Core_list.map ~f:map_reason rs)
  | EBindingError (b, loc, s, scope) -> EBindingError (b, f loc, s, scope)
  | ERecursionLimit (r1, r2) -> ERecursionLimit (map_reason r1, map_reason r2)
  | EModuleOutsideRoot (loc, s) -> EModuleOutsideRoot (f loc, s)
  | EMalformedPackageJson (loc, s) -> EMalformedPackageJson (f loc, s)
  | EExperimentalDecorators loc -> EExperimentalDecorators (f loc)
  | EExperimentalClassProperties (loc, b) -> EExperimentalClassProperties (f loc, b)
  | EUnsafeGetSet loc -> EUnsafeGetSet (f loc)
  | EUninitializedInstanceProperty (loc, e) -> EUninitializedInstanceProperty (f loc, e)
  | EExperimentalExportStarAs loc -> EExperimentalExportStarAs (f loc)
  | EExperimentalEnums loc -> EExperimentalEnums (f loc)
  | EIndeterminateModuleType loc -> EIndeterminateModuleType (f loc)
  | EBadExportPosition loc -> EBadExportPosition (f loc)
  | EBadExportContext (s, loc) -> EBadExportContext (s, f loc)
  | EUnreachable loc -> EUnreachable (f loc)
  | EInvalidTypeof (loc, s) -> EInvalidTypeof (f loc, s)
  | EBinaryInLHS r -> EBinaryInLHS (map_reason r)
  | EBinaryInRHS r -> EBinaryInRHS (map_reason r)
  | EArithmeticOperand r -> EArithmeticOperand (map_reason r)
  | EForInRHS r -> EForInRHS (map_reason r)
  | EObjectComputedPropertyAccess (r1, r2) ->
    EObjectComputedPropertyAccess (map_reason r1, map_reason r2)
  | EObjectComputedPropertyAssign (r1, r2) ->
    EObjectComputedPropertyAssign (map_reason r1, map_reason r2)
  | EInvalidLHSInAssignment l -> EInvalidLHSInAssignment (f l)
  | EUnsupportedImplements r -> EUnsupportedImplements (map_reason r)
  | EReactElementFunArity (r, s, i) -> EReactElementFunArity (map_reason r, s, i)
  | EUnsupportedSetProto r -> EUnsupportedSetProto (map_reason r)
  | EDuplicateModuleProvider { module_name; provider; conflict } ->
    EDuplicateModuleProvider { module_name; provider = f provider; conflict = f conflict }
  | EParseError (loc, p) -> EParseError (f loc, p)
  | EDocblockError (loc, e) -> EDocblockError (f loc, e)
  | EImplicitInexactObject loc -> EImplicitInexactObject (f loc)
  | EUntypedTypeImport (loc, s) -> EUntypedTypeImport (f loc, s)
  | EUntypedImport (loc, s) -> EUntypedImport (f loc, s)
  | ENonstrictImport loc -> ENonstrictImport (f loc)
  | EUnclearType loc -> EUnclearType (f loc)
  | EDeprecatedType loc -> EDeprecatedType (f loc)
  | EDeprecatedUtility (loc, s) -> EDeprecatedUtility (f loc, s)
  | EDynamicExport (r1, r2) -> EDynamicExport (map_reason r1, map_reason r2)
  | EUnsafeGettersSetters loc -> EUnsafeGettersSetters (f loc)
  | EUnusedSuppression loc -> EUnusedSuppression (f loc)
  | ELintSetting (loc, err) -> ELintSetting (f loc, err)
  | ESketchyNullLint { kind; loc; null_loc; falsy_loc } ->
    ESketchyNullLint { kind; loc = f loc; null_loc = f null_loc; falsy_loc = f falsy_loc }
  | ESketchyNumberLint (kind, r) -> ESketchyNumberLint (kind, map_reason r)
  | EInvalidPrototype r -> EInvalidPrototype (map_reason r)
  | EExperimentalOptionalChaining loc -> EExperimentalOptionalChaining (f loc)
  | EOptionalChainingMethods loc -> EOptionalChainingMethods (f loc)
  | EUnnecessaryOptionalChain (loc, r) -> EUnnecessaryOptionalChain (f loc, map_reason r)
  | EUnnecessaryInvariant (loc, r) -> EUnnecessaryInvariant (f loc, map_reason r)
  | EInexactSpread (r1, r2) -> EInexactSpread (map_reason r1, map_reason r2)
  | EUnexpectedTemporaryBaseType loc -> EUnexpectedTemporaryBaseType (f loc)
  | ECannotDelete (l1, r1) -> ECannotDelete (f l1, map_reason r1)
  | EBigIntNotYetSupported r -> EBigIntNotYetSupported (map_reason r)
  | ESignatureVerification sve -> ESignatureVerification (Signature_error.map_locs ~f sve)
  | ENonArraySpread r -> ENonArraySpread (map_reason r)
  | ECannotSpreadInterface { spread_reason; interface_reason } ->
    ECannotSpreadInterface
      { spread_reason = map_reason spread_reason; interface_reason = map_reason interface_reason }
  | ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason } ->
    ECannotSpreadIndexerOnRight
      {
        spread_reason = map_reason spread_reason;
        object_reason = map_reason object_reason;
        key_reason = map_reason key_reason;
      }
  | EUnableToSpread { spread_reason; object1_reason; object2_reason; propname; error_kind } ->
    EUnableToSpread
      {
        spread_reason = map_reason spread_reason;
        object1_reason = map_reason object1_reason;
        object2_reason = map_reason object2_reason;
        propname;
        error_kind;
      }
  | EInexactMayOverwriteIndexer { spread_reason; key_reason; value_reason; object2_reason } ->
    EInexactMayOverwriteIndexer
      {
        spread_reason = map_reason spread_reason;
        key_reason = map_reason key_reason;
        value_reason = map_reason value_reason;
        object2_reason = map_reason object2_reason;
      }
  | EExponentialSpread { reason; reasons_for_operand1; reasons_for_operand2 } ->
    EExponentialSpread
      {
        reason = map_reason reason;
        reasons_for_operand1 = Nel.map map_reason reasons_for_operand1;
        reasons_for_operand2 = Nel.map map_reason reasons_for_operand2;
      }
  | EComputedPropertyWithMultipleLowerBounds
      { computed_property_reason; new_lower_bound_reason; existing_lower_bound_reason } ->
    EComputedPropertyWithMultipleLowerBounds
      {
        computed_property_reason = map_reason computed_property_reason;
        new_lower_bound_reason = map_reason new_lower_bound_reason;
        existing_lower_bound_reason = map_reason existing_lower_bound_reason;
      }
  | EComputedPropertyWithUnion { computed_property_reason; union_reason } ->
    EComputedPropertyWithUnion
      {
        computed_property_reason = map_reason computed_property_reason;
        union_reason = map_reason union_reason;
      }

let desc_of_reason r = Reason.desc_of_reason ~unwrap:(is_scalar_reason r) r

(* A utility function for getting and updating the use_op in error messages. *)
let util_use_op_of_msg nope util = function
  | EIncompatible { use_op; lower; upper; branches } ->
    Option.value_map use_op ~default:nope ~f:(fun use_op ->
        util use_op (fun use_op -> EIncompatible { use_op = Some use_op; lower; upper; branches }))
  | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
    util use_op (fun use_op -> EIncompatibleDefs { use_op; reason_lower; reason_upper; branches })
  | EIncompatibleProp { use_op; prop; reason_prop; reason_obj; special } ->
    Option.value_map use_op ~default:nope ~f:(fun use_op ->
        util use_op (fun use_op ->
            EIncompatibleProp { use_op = Some use_op; prop; reason_prop; reason_obj; special }))
  | ETrustIncompatibleWithUseOp (rl, ru, op) ->
    util op (fun op -> ETrustIncompatibleWithUseOp (rl, ru, op))
  | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedStringLit { reason_lower; reason_upper; use_op })
  | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedNumberLit { reason_lower; reason_upper; use_op })
  | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedBooleanLit { reason_lower; reason_upper; use_op })
  | EPropNotFound (prop, rs, op) -> util op (fun op -> EPropNotFound (prop, rs, op))
  | EPropNotReadable { reason_prop; prop_name; use_op } ->
    util use_op (fun use_op -> EPropNotReadable { reason_prop; prop_name; use_op })
  | EPropNotWritable { reason_prop; prop_name; use_op } ->
    util use_op (fun use_op -> EPropNotWritable { reason_prop; prop_name; use_op })
  | EPropPolarityMismatch (rs, p, ps, op) ->
    util op (fun op -> EPropPolarityMismatch (rs, p, ps, op))
  | EStrictLookupFailed { reason_prop; reason_obj; name; use_op = Some op } ->
    util op (fun op -> EStrictLookupFailed { reason_prop; reason_obj; name; use_op = Some op })
  | EPrivateLookupFailed (rs, x, op) -> util op (fun op -> EPrivateLookupFailed (rs, x, op))
  | EAdditionMixed (r, op) -> util op (fun op -> EAdditionMixed (r, op))
  | ETupleArityMismatch (rs, x, y, op) -> util op (fun op -> ETupleArityMismatch (rs, x, y, op))
  | ENonLitArrayToTuple (rs, op) -> util op (fun op -> ENonLitArrayToTuple (rs, op))
  | ETupleOutOfBounds { use_op; reason; reason_op; length; index } ->
    util use_op (fun use_op -> ETupleOutOfBounds { use_op; reason; reason_op; length; index })
  | ETupleNonIntegerIndex { use_op; reason; index } ->
    util use_op (fun use_op -> ETupleNonIntegerIndex { use_op; reason; index })
  | ETupleUnsafeWrite { reason; use_op } ->
    util use_op (fun use_op -> ETupleUnsafeWrite { reason; use_op })
  | EROArrayWrite (rs, op) -> util op (fun op -> EROArrayWrite (rs, op))
  | EUnionSpeculationFailed { use_op; reason; reason_op; branches } ->
    util use_op (fun use_op -> EUnionSpeculationFailed { use_op; reason; reason_op; branches })
  | EIncompatibleWithExact (rs, op) -> util op (fun op -> EIncompatibleWithExact (rs, op))
  | EInvalidCharSet { invalid; valid; use_op } ->
    util use_op (fun use_op -> EInvalidCharSet { invalid; valid; use_op })
  | EIncompatibleWithShape (l, u, use_op) ->
    util use_op (fun use_op -> EIncompatibleWithShape (l, u, use_op))
  | EInvalidObjectKit { reason; reason_op; use_op } ->
    util use_op (fun use_op -> EInvalidObjectKit { reason; reason_op; use_op })
  | EIncompatibleWithUseOp (rl, ru, op) -> util op (fun op -> EIncompatibleWithUseOp (rl, ru, op))
  | ENotAReactComponent { reason; use_op } ->
    util use_op (fun use_op -> ENotAReactComponent { reason; use_op })
  | EInvalidReactConfigType { reason; use_op } ->
    util use_op (fun use_op -> EInvalidReactConfigType { reason; use_op })
  | EInvalidReactPropType { reason; use_op; tool } ->
    util use_op (fun use_op -> EInvalidReactPropType { reason; use_op; tool })
  | EInvalidReactCreateClass { reason; use_op; tool } ->
    util use_op (fun use_op -> EInvalidReactCreateClass { reason; use_op; tool })
  | EFunctionCallExtraArg (rl, ru, n, op) ->
    util op (fun op -> EFunctionCallExtraArg (rl, ru, n, op))
  | EDebugPrint (_, _)
  | EExportValueAsType (_, _)
  | EImportValueAsType (_, _)
  | EImportTypeAsTypeof (_, _)
  | EImportTypeAsValue (_, _)
  | ERefineAsValue (_, _)
  | ENoDefaultExport (_, _, _)
  | EOnlyDefaultExport (_, _, _)
  | ENoNamedExport (_, _, _, _)
  | EMissingTypeArgs { reason_tapp = _; reason_arity = _; min_arity = _; max_arity = _ }
  | EValueUsedAsType _
  | EPolarityMismatch { reason = _; name = _; expected_polarity = _; actual_polarity = _ }
  | EBuiltinLookupFailed _
  | EStrictLookupFailed { use_op = None; _ }
  | EComparison (_, _)
  | ESpeculationAmbiguous _
  | EUnsupportedExact (_, _)
  | EIdxArity _
  | EIdxUse1 _
  | EIdxUse2 _
  | EUnexpectedThisType _
  | ETypeParamArity (_, _)
  | ECallTypeArity _
  | ETypeParamMinArity (_, _)
  | ETooManyTypeArgs (_, _, _)
  | ETooFewTypeArgs (_, _, _)
  | EInvalidTypeArgs (_, _)
  | EPropertyTypeAnnot _
  | EExportsAnnot _
  | ECharSetAnnot _
  | EUnsupportedKeyInObjectType _
  | EPredAnnot _
  | ERefineAnnot _
  | ETrustedAnnot _
  | EPrivateAnnot _
  | EUnexpectedTypeof _
  | EFunPredCustom (_, _)
  | EInternal (_, _)
  | EUnsupportedSyntax (_, _)
  | EUseArrayLiteral _
  | EMissingAnnotation _
  | EBindingError (_, _, _, _)
  | ERecursionLimit (_, _)
  | EModuleOutsideRoot (_, _)
  | EMalformedPackageJson (_, _)
  | EExperimentalDecorators _
  | EExperimentalClassProperties (_, _)
  | EUnsafeGetSet _
  | EUninitializedInstanceProperty _
  | EExperimentalExportStarAs _
  | EExperimentalEnums _
  | EIndeterminateModuleType _
  | EBadExportPosition _
  | EBadExportContext _
  | EUnreachable _
  | EInvalidTypeof (_, _)
  | EBinaryInLHS _
  | EBinaryInRHS _
  | EArithmeticOperand _
  | EForInRHS _
  | EObjectComputedPropertyAccess (_, _)
  | EObjectComputedPropertyAssign (_, _)
  | EInvalidLHSInAssignment _
  | EUnsupportedImplements _
  | EReactElementFunArity (_, _, _)
  | EUnsupportedSetProto _
  | EDuplicateModuleProvider { module_name = _; provider = _; conflict = _ }
  | EParseError (_, _)
  | EDocblockError (_, _)
  | EImplicitInexactObject _
  | EUntypedTypeImport (_, _)
  | EUntypedImport (_, _)
  | ENonstrictImport _
  | EUnclearType _
  | EDeprecatedType _
  | EDeprecatedUtility _
  | EDynamicExport _
  | EUnsafeGettersSetters _
  | EUnusedSuppression _
  | ELintSetting _
  | ESketchyNullLint { kind = _; loc = _; null_loc = _; falsy_loc = _ }
  | ESketchyNumberLint _
  | EInvalidPrototype _
  | EExperimentalOptionalChaining _
  | EOptionalChainingMethods _
  | EUnnecessaryOptionalChain _
  | EUnnecessaryInvariant _
  | EInexactSpread _
  | EUnexpectedTemporaryBaseType _
  | ECannotDelete _
  | EBigIntNotYetSupported _
  | ESignatureVerification _
  | ENonArraySpread _
  | ECannotSpreadInterface _
  | ECannotSpreadIndexerOnRight _
  | EUnableToSpread _
  | EInexactMayOverwriteIndexer _
  | EExponentialSpread _
  | EComputedPropertyWithMultipleLowerBounds _
  | EComputedPropertyWithUnion _ ->
    nope

(* Not all messages (i.e. those whose locations are based on use_ops) have locations that can be
  determined while locations are abstract. We just return None in this case. *)
let aloc_of_msg : t -> ALoc.t option = function
  | EValueUsedAsType { reason_use = primary }
  | EComparison (primary, _)
  | EFunPredCustom ((primary, _), _)
  | EDynamicExport (_, primary)
  | EInexactSpread (_, primary)
  | EInvalidTypeArgs (_, primary)
  | ETooFewTypeArgs (primary, _, _)
  | ETooManyTypeArgs (primary, _, _) ->
    Some (aloc_of_reason primary)
  | ESketchyNumberLint (_, reason)
  | EInvalidPrototype reason
  | EBigIntNotYetSupported reason
  | EUnsupportedSetProto reason
  | EReactElementFunArity (reason, _, _)
  | EUnsupportedImplements reason
  | EObjectComputedPropertyAssign (_, reason)
  | EObjectComputedPropertyAccess (_, reason)
  | EForInRHS reason
  | EBinaryInRHS reason
  | EBinaryInLHS reason
  | EArithmeticOperand reason
  | ERecursionLimit (reason, _)
  | EMissingAnnotation (reason, _)
  | EIdxArity reason
  | EIdxUse1 reason
  | EIdxUse2 reason
  | EUnsupportedExact (_, reason)
  | EPolarityMismatch { reason; _ }
  | ENoNamedExport (reason, _, _, _)
  | EOnlyDefaultExport (reason, _, _)
  | ENoDefaultExport (reason, _, _)
  | ERefineAsValue (reason, _)
  | EImportTypeAsValue (reason, _)
  | EImportTypeAsTypeof (reason, _)
  | EExportValueAsType (reason, _)
  | EImportValueAsType (reason, _)
  | EDebugPrint (reason, _)
  | ENonArraySpread reason
  | EComputedPropertyWithMultipleLowerBounds
      {
        computed_property_reason = reason;
        new_lower_bound_reason = _;
        existing_lower_bound_reason = _;
      }
  | EComputedPropertyWithUnion { computed_property_reason = reason; union_reason = _ } ->
    Some (aloc_of_reason reason)
  (* We position around the use of the object instead of the spread because the
   * spread may be part of a polymorphic type signature. If we add a suppression there,
   * the reduction in coverage is far more drastic. *)
  | ECannotSpreadInterface { spread_reason = _; interface_reason = reason }
  | ECannotSpreadIndexerOnRight { spread_reason = _; object_reason = reason; key_reason = _ }
  | EUnableToSpread
      {
        spread_reason = _;
        object1_reason = _;
        object2_reason = reason;
        propname = _;
        error_kind = _;
      }
  | EInexactMayOverwriteIndexer
      { spread_reason = _; key_reason = _; value_reason = _; object2_reason = reason } ->
    Some (aloc_of_reason reason)
  | EExponentialSpread { reason = _; reasons_for_operand1; reasons_for_operand2 } ->
    (* Ideally, we have an actual annotated union in here somewhere. This function tries to find
     * it, otherwise our primary location will be around the first reason in the list of reasons
     * for the first spread operand.
     *
     * It's important that we don't position around the location of the spread because that
     * may be a polymorphic type variable.
     *
     * TODO (jmbrown): Maybe we should have two separate errors here-- one for type spread and
     * one for value spread. It's always safe to position the error around the value spread.
     * The same is true for all of the other spread errors.
     *)
    let union_reason =
      match (reasons_for_operand1, reasons_for_operand2) with
      | ((r, []), _)
      | (_, (r, [])) ->
        r
      | ((r, _), _) -> r
    in
    Some (aloc_of_reason union_reason)
  | EUntypedTypeImport (loc, _)
  | EUntypedImport (loc, _)
  | ENonstrictImport loc
  | EUnclearType loc
  | EDeprecatedType loc
  | EDeprecatedUtility (loc, _)
  | EUnsafeGettersSetters loc
  | EUnnecessaryOptionalChain (loc, _)
  | EUnnecessaryInvariant (loc, _)
  | EOptionalChainingMethods loc
  | EExperimentalOptionalChaining loc
  | EUnusedSuppression loc
  | EDocblockError (loc, _)
  | EImplicitInexactObject loc
  | EParseError (loc, _)
  | EInvalidLHSInAssignment loc
  | EInvalidTypeof (loc, _)
  | EUnreachable loc
  | EUnexpectedTemporaryBaseType loc
  | ECannotDelete (loc, _)
  | EBadExportContext (_, loc)
  | EBadExportPosition loc
  | EIndeterminateModuleType loc
  | EExperimentalExportStarAs loc
  | EExperimentalEnums loc
  | EUnsafeGetSet loc
  | EUninitializedInstanceProperty (loc, _)
  | EExperimentalClassProperties (loc, _)
  | EExperimentalDecorators loc
  | EModuleOutsideRoot (loc, _)
  | EMalformedPackageJson (loc, _)
  | EUseArrayLiteral loc
  | EUnsupportedSyntax (loc, _)
  | EInternal (loc, _)
  | EUnexpectedTypeof loc
  | EPrivateAnnot loc
  | ETrustedAnnot loc
  | ERefineAnnot loc
  | EPredAnnot loc
  | EUnsupportedKeyInObjectType loc
  | ECharSetAnnot loc
  | EExportsAnnot loc
  | EPropertyTypeAnnot loc
  | EUnexpectedThisType loc
  | ETypeParamMinArity (loc, _) ->
    Some loc
  | ELintSetting (loc, _) -> Some loc
  | ETypeParamArity (loc, _) -> Some loc
  | ESketchyNullLint { loc; _ } -> Some loc
  | ECallTypeArity { call_loc; _ } -> Some call_loc
  | EMissingTypeArgs { reason_tapp; _ } -> Some (aloc_of_reason reason_tapp)
  | ESignatureVerification sve ->
    Signature_error.(
      (match sve with
      | ExpectedSort (_, _, loc)
      | ExpectedAnnotation (loc, _)
      | InvalidTypeParamUse loc
      | UnexpectedObjectKey (loc, _)
      | UnexpectedObjectSpread (loc, _)
      | UnexpectedArraySpread (loc, _)
      | UnexpectedArrayHole loc
      | EmptyArray loc
      | EmptyObject loc
      | UnexpectedExpression (loc, _)
      | SketchyToplevelDef loc
      | UnsupportedPredicateExpression loc
      | TODO (_, loc) ->
        Some loc))
  | EDuplicateModuleProvider { conflict; _ } -> Some conflict
  | EBindingError (_, loc, _, _) -> Some loc
  | ESpeculationAmbiguous { reason; _ } -> Some (aloc_of_reason reason)
  | EBuiltinLookupFailed { reason; _ } -> Some (aloc_of_reason reason)
  | EFunctionCallExtraArg _
  | ENotAReactComponent _
  | EInvalidReactConfigType _
  | EInvalidReactPropType _
  | EInvalidReactCreateClass _
  | EIncompatibleWithUseOp _
  | ETrustIncompatibleWithUseOp _
  | EIncompatibleDefs _
  | EInvalidObjectKit _
  | EIncompatibleWithShape _
  | EInvalidCharSet _
  | EIncompatibleWithExact _
  | EUnionSpeculationFailed _
  | ETupleUnsafeWrite _
  | EROArrayWrite _
  | ETupleOutOfBounds _
  | ETupleNonIntegerIndex _
  | ENonLitArrayToTuple _
  | ETupleArityMismatch _
  | EAdditionMixed _
  | EPrivateLookupFailed _
  | EStrictLookupFailed _
  | EPropPolarityMismatch _
  | EPropNotReadable _
  | EPropNotWritable _
  | EPropNotFound _
  | EExpectedBooleanLit _
  | EExpectedNumberLit _
  | EExpectedStringLit _
  | EIncompatibleProp _
  | EIncompatible _ ->
    None

let kind_of_msg =
  Errors.(
    function
    | EUntypedTypeImport _ -> LintError Lints.UntypedTypeImport
    | EUntypedImport _ -> LintError Lints.UntypedImport
    | ENonstrictImport _ -> LintError Lints.NonstrictImport
    | EUnclearType _ -> LintError Lints.UnclearType
    | EDeprecatedType _ -> LintError Lints.DeprecatedType
    | EDeprecatedUtility _ -> LintError Lints.DeprecatedUtility
    | EDynamicExport _ -> LintError Lints.DynamicExport
    | EUnsafeGettersSetters _ -> LintError Lints.UnsafeGettersSetters
    | ESketchyNullLint { kind; _ } -> LintError (Lints.SketchyNull kind)
    | ESketchyNumberLint (kind, _) -> LintError (Lints.SketchyNumber kind)
    | EUnnecessaryOptionalChain _ -> LintError Lints.UnnecessaryOptionalChain
    | EUnnecessaryInvariant _ -> LintError Lints.UnnecessaryInvariant
    | EInexactSpread _ -> LintError Lints.InexactSpread
    | ESignatureVerification _ -> LintError Lints.SignatureVerificationFailure
    | EImplicitInexactObject _ -> LintError Lints.ImplicitInexactObject
    | EUninitializedInstanceProperty _ -> LintError Lints.UninitializedInstanceProperty
    | ENonArraySpread _ -> LintError Lints.NonArraySpread
    | EBadExportPosition _
    | EBadExportContext _ ->
      InferWarning ExportKind
    | EUnexpectedTypeof _
    | EExperimentalDecorators _
    | EExperimentalClassProperties _
    | EUnsafeGetSet _
    | EExperimentalExportStarAs _
    | EExperimentalEnums _
    | EIndeterminateModuleType _
    | EUnreachable _
    | EInvalidTypeof _ ->
      InferWarning OtherKind
    | EInternal _ -> InternalError
    | ERecursionLimit _ -> RecursionLimitError
    | EDuplicateModuleProvider _ -> DuplicateProviderError
    | EParseError _ -> ParseError
    | EDocblockError _
    | ELintSetting _
    | EExperimentalOptionalChaining _
    | EOptionalChainingMethods _ ->
      PseudoParseError
    | _ -> InferError)

let mk_prop_message =
  Errors.Friendly.(
    function
    | None
    | Some "$key"
    | Some "$value" ->
      [text "an index signature declaring the expected key / value type"]
    | Some "$call" -> [text "a call signature declaring the expected parameter / return type"]
    | Some prop -> [text "property "; code prop])

let string_of_internal_error = function
  | PackageHeapNotFound pkg -> spf "package %S was not found in the PackageHeap!" pkg
  | AbnormalControlFlow -> "abnormal control flow"
  | MethodNotAFunction -> "expected function type"
  | OptionalMethod -> "optional methods are not supported"
  | OpenPredWithoutSubst -> "OpenPredT ~> OpenPredT without substitution"
  | PredFunWithoutParamNames -> "FunT -> FunT no params"
  | UnsupportedGuardPredicate pred -> spf "unsupported guard predicate (%s)" pred
  | BreakEnvMissingForCase -> "break env missing for case"
  | PropertyDescriptorPropertyCannotBeRead -> "unexpected property in properties object"
  | ForInLHS -> "unexpected LHS in for...in"
  | ForOfLHS -> "unexpected LHS in for...of"
  | InstanceLookupComputed -> "unexpected computed property lookup on InstanceT"
  | PropRefComputedOpen -> "unexpected open computed property element type"
  | PropRefComputedLiteral -> "unexpected literal computed property element type"
  | ShadowReadComputed -> "unexpected shadow read on computed property"
  | ShadowWriteComputed -> "unexpected shadow write on computed property"
  | RestParameterNotIdentifierPattern ->
    "unexpected rest parameter, expected an identifier pattern"
  | InterfaceTypeSpread -> "unexpected spread property in interface"
  | DebugThrow -> "debug throw"
  | MergeTimeout s -> spf "merge job timed out after %0.2f seconds" s
  | MergeJobException exc -> "uncaught exception: " ^ Exception.to_string exc
  | CheckTimeout s -> spf "check job timed out after %0.2f seconds" s
  | CheckJobException exc -> "uncaught exception: " ^ Exception.to_string exc
  | UnexpectedTypeapp s -> "unexpected typeapp: " ^ s

(* Friendly messages are created differently based on the specific error they come from, so
   we collect the ingredients here and pass them to make_error_printable *)
type 'loc friendly_message_recipe =
  | IncompatibleUse of {
      loc: 'loc;
      upper_kind: 'loc upper_kind;
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | Speculation of {
      loc: 'loc;
      use_op: 'loc Type.virtual_use_op;
      branches: ('loc Reason.virtual_reason * t) list;
    }
  | Incompatible of {
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | IncompatibleTrust of {
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | PropMissing of {
      loc: 'loc;
      prop: string option;
      reason_obj: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | Normal of { features: 'loc Errors.Friendly.message_feature list }
  | UseOp of {
      loc: 'loc;
      features: 'loc Errors.Friendly.message_feature list;
      use_op: 'loc Type.virtual_use_op;
    }
  | PropPolarityMismatch of {
      prop: string option;
      reason_lower: 'loc Reason.virtual_reason;
      polarity_lower: Polarity.t;
      reason_upper: 'loc Reason.virtual_reason;
      polarity_upper: Polarity.t;
      use_op: 'loc Type.virtual_use_op;
    }

let friendly_message_of_msg : Loc.t t' -> Loc.t friendly_message_recipe =
  let text = Errors.Friendly.text in
  let code = Errors.Friendly.code in
  let ref = Errors.Friendly.ref in
  let desc = Errors.Friendly.ref ~loc:false in
  let msg_export prefix export_name =
    if export_name = "default" then
      (text "", text "the default export")
    else
      (text prefix, code export_name)
  in
  Errors.(
    function
    | EIncompatible
        { lower = (reason_lower, _); upper = (reason_upper, upper_kind); use_op; branches } ->
      if branches = [] then
        IncompatibleUse
          {
            loc = loc_of_reason reason_upper;
            upper_kind;
            reason_lower;
            reason_upper;
            use_op = Option.value ~default:unknown_use use_op;
          }
      else
        Speculation
          {
            loc = loc_of_reason reason_upper;
            use_op = Option.value ~default:unknown_use use_op;
            branches;
          }
    | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
      if branches = [] then
        Incompatible { reason_lower; reason_upper; use_op }
      else
        Speculation { loc = loc_of_reason reason_upper; use_op; branches }
    | EIncompatibleProp { prop; reason_prop; reason_obj; special = _; use_op } ->
      PropMissing
        {
          loc = loc_of_reason reason_prop;
          prop;
          reason_obj;
          use_op = Option.value ~default:unknown_use use_op;
        }
    | EDebugPrint (_, str) -> Normal { features = [text str] }
    | EExportValueAsType (_, export_name) ->
      Normal { features = [text "Cannot export the value "; code export_name; text " as a type."] }
    | EImportValueAsType (_, export_name) ->
      let (prefix, export) = msg_export "the value " export_name in
      let features =
        [
          text "Cannot import ";
          prefix;
          export;
          text " as a type. ";
          code "import type";
          text " only works on type exports like type aliases, ";
          text "interfaces, and classes. If you intended to import the type of a ";
          text "value use ";
          code "import typeof";
          text " instead.";
        ]
      in
      Normal { features }
    | EImportTypeAsTypeof (_, export_name) ->
      let (prefix, export) = msg_export "the type " export_name in
      let features =
        [
          text "Cannot import ";
          prefix;
          export;
          text " as a type. ";
          code "import typeof";
          text " only works on value exports like variables, ";
          text "functions, and classes. If you intended to import a type use ";
          code "import type";
          text " instead.";
        ]
      in
      Normal { features }
    | EImportTypeAsValue (_, export_name) ->
      let (prefix, export) = msg_export "the type " export_name in
      let features =
        [
          text "Cannot import ";
          prefix;
          export;
          text " as a value. ";
          text "Use ";
          code "import type";
          text " instead.";
        ]
      in
      Normal { features }
    | ERefineAsValue (_, name) ->
      let (_, export) = msg_export "" name in
      let features = [text "Cannot refine "; export; text " as a value. "] in
      Normal { features }
    | ENoDefaultExport (_, module_name, suggestion) ->
      let features =
        [
          text "Cannot import a default export because there is no default export ";
          text "in ";
          code module_name;
          text ".";
        ]
        @
        match suggestion with
        | None -> []
        | Some suggestion ->
          [
            text " ";
            text "Did you mean ";
            code (spf "import {%s} from \"%s\"" suggestion module_name);
            text "?";
          ]
      in
      Normal { features }
    | EOnlyDefaultExport (_, module_name, export_name) ->
      let features =
        [
          text "Cannot import ";
          code export_name;
          text " because ";
          text "there is no ";
          code export_name;
          text " export in ";
          code module_name;
          text ". Did you mean ";
          code (spf "import %s from \"...\"" export_name);
          text "?";
        ]
      in
      Normal { features }
    | ENoNamedExport (_, module_name, export_name, suggestion) ->
      let features =
        [
          text "Cannot import ";
          code export_name;
          text " because ";
          text "there is no ";
          code export_name;
          text " export in ";
          code module_name;
          text ".";
        ]
        @
        match suggestion with
        | None -> []
        | Some suggestion -> [text " Did you mean "; code suggestion; text "?"]
      in
      Normal { features }
    | EMissingTypeArgs { reason_tapp; reason_arity; min_arity; max_arity } ->
      let (arity, args) =
        if min_arity = max_arity then
          ( spf "%d" max_arity,
            if max_arity = 1 then
              "argument"
            else
              "arguments" )
        else
          (spf "%d-%d" min_arity max_arity, "arguments")
      in
      let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
      let features =
        [text "Cannot use "; ref reason_arity; text (spf " without %s type %s." arity args)]
      in
      Normal { features }
    | ETooManyTypeArgs (reason_tapp, reason_arity, n) ->
      let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
      let features =
        [
          text "Cannot use ";
          ref reason_arity;
          text " with more than ";
          text
            (spf
               "%n type %s."
               n
               ( if n == 1 then
                 "argument"
               else
                 "arguments" ));
        ]
      in
      Normal { features }
    | ETooFewTypeArgs (reason_tapp, reason_arity, n) ->
      let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
      let features =
        [
          text "Cannot use ";
          ref reason_arity;
          text " with fewer than ";
          text
            (spf
               "%n type %s."
               n
               ( if n == 1 then
                 "argument"
               else
                 "arguments" ));
        ]
      in
      Normal { features }
    | EInvalidTypeArgs (reason_main, reason_tapp) ->
      let features =
        [text "Cannot use "; ref reason_main; text " with "; ref reason_tapp; text " argument"]
      in
      Normal { features }
    | ETypeParamArity (_, n) ->
      if n = 0 then
        Normal { features = [text "Cannot apply type because it is not a polymorphic type."] }
      else
        let features =
          [
            text "Cannot use type without exactly ";
            text
              (spf
                 "%n type %s."
                 n
                 ( if n == 1 then
                   "argument"
                 else
                   "arguments" ));
          ]
        in
        Normal { features }
    | ETypeParamMinArity (_, n) ->
      let features =
        [
          text "Cannot use type without at least ";
          text
            (spf
               "%n type %s."
               n
               ( if n == 1 then
                 "argument"
               else
                 "arguments" ));
        ]
      in
      Normal { features }
    | ECallTypeArity { call_loc = _; is_new; reason_arity; expected_arity = n } ->
      let use =
        if is_new then
          "construct "
        else
          "call "
      in
      if n = 0 then
        let features =
          [
            text "Cannot ";
            text use;
            text "non-polymorphic ";
            ref reason_arity;
            text " with type arguments.";
          ]
        in
        Normal { features }
      else
        let features =
          [
            text "Cannot ";
            text use;
            ref reason_arity;
            text " without exactly ";
            text
              (spf
                 "%n type argument%s."
                 n
                 ( if n == 1 then
                   ""
                 else
                   "s" ));
          ]
        in
        Normal { features }
    | EValueUsedAsType { reason_use } ->
      let features =
        [
          text "Cannot use ";
          desc reason_use;
          text " as a type. ";
          text "A name can be used as a type only if it refers to ";
          text "a type definition, an interface definition, or a class definition. ";
          text "To get the type of a non-class value, use ";
          code "typeof";
          text ".";
        ]
      in
      Normal { features }
    | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
      Incompatible { reason_lower; reason_upper; use_op }
    | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
      Incompatible { reason_lower; reason_upper; use_op }
    | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
      Incompatible { reason_lower; reason_upper; use_op }
    | EPropNotFound (prop, reasons, use_op) ->
      let (reason_prop, reason_obj) = reasons in
      PropMissing { loc = loc_of_reason reason_prop; prop; reason_obj; use_op }
    | EPropNotReadable { reason_prop; prop_name = x; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason_prop;
          features = mk_prop_message x @ [text " is not readable"];
          use_op;
        }
    | EPropNotWritable { reason_prop; prop_name = x; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason_prop;
          features = mk_prop_message x @ [text " is not writable"];
          use_op;
        }
    | EPropPolarityMismatch
        ((reason_lower, reason_upper), prop, (polarity_lower, polarity_upper), use_op) ->
      PropPolarityMismatch
        { prop; reason_lower; polarity_lower; reason_upper; polarity_upper; use_op }
    | EPolarityMismatch { reason; name; expected_polarity; actual_polarity } ->
      let polarity_string = function
        | Polarity.Positive -> "output"
        | Polarity.Negative -> "input"
        | Polarity.Neutral -> "input/output"
      in
      let expected_polarity = polarity_string expected_polarity in
      let actual_polarity = polarity_string actual_polarity in
      let reason_targ = mk_reason (RIdentifier name) (def_loc_of_reason reason) in
      let features =
        [
          text "Cannot use ";
          ref reason_targ;
          text (" in an " ^ actual_polarity ^ " ");
          text "position because ";
          ref reason_targ;
          text " is expected to occur only in ";
          text (expected_polarity ^ " positions.");
        ]
      in
      Normal { features }
    | EBuiltinLookupFailed { reason; name } ->
      let features =
        match name with
        | Some x when is_internal_module_name x ->
          [text "Cannot resolve module "; code (uninternal_module_name x); text "."]
        | None -> [text "Cannot resolve name "; desc reason; text "."]
        | Some x when is_internal_name x -> [text "Cannot resolve name "; desc reason; text "."]
        | Some x -> [text "Cannot resolve name "; code x; text "."]
      in
      Normal { features }
    | EStrictLookupFailed { reason_prop; reason_obj; name; use_op } ->
      PropMissing
        {
          loc = loc_of_reason reason_prop;
          prop = name;
          reason_obj;
          use_op = Option.value ~default:unknown_use use_op;
        }
    | EPrivateLookupFailed (reasons, x, use_op) ->
      PropMissing
        {
          loc = loc_of_reason (fst reasons);
          prop = Some ("#" ^ x);
          reason_obj = snd reasons;
          use_op;
        }
    | EAdditionMixed (reason, use_op) ->
      UseOp
        {
          loc = loc_of_reason reason;
          features = [ref reason; text " could either behave like a string or like a number"];
          use_op;
        }
    | EComparison (lower, upper) ->
      Normal { features = [text "Cannot compare "; ref lower; text " to "; ref upper; text "."] }
    | ETupleArityMismatch (reasons, l1, l2, use_op) ->
      let (lower, upper) = reasons in
      UseOp
        {
          loc = loc_of_reason lower;
          features =
            [
              ref lower;
              text (spf " has an arity of %d but " l1);
              ref upper;
              text (spf " has an arity of %d" l2);
            ];
          use_op;
        }
    | ENonLitArrayToTuple (reasons, use_op) ->
      let (lower, upper) = reasons in
      UseOp
        {
          loc = loc_of_reason lower;
          features =
            [
              ref lower;
              text " has an unknown number of elements, so is ";
              text "incompatible with ";
              ref upper;
            ];
          use_op;
        }
    | ETupleOutOfBounds { reason; reason_op; length; index; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason;
          features =
            [
              ref reason_op;
              text
                (spf
                   " only has %d element%s, so index %s is out of bounds"
                   length
                   ( if length == 1 then
                     ""
                   else
                     "s" )
                   index);
            ];
          use_op;
        }
    | ETupleNonIntegerIndex { reason; index; use_op } ->
      let index_ref = Errors.Friendly.(Reference ([Code index], def_loc_of_reason reason)) in
      UseOp
        {
          loc = loc_of_reason reason;
          features =
            [
              text "the index into a tuple must be an integer, but ";
              index_ref;
              text " is not an integer";
            ];
          use_op;
        }
    | ETupleUnsafeWrite { reason; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason;
          features = [text "the index must be statically known to write a tuple element"];
          use_op;
        }
    | EROArrayWrite (reasons, use_op) ->
      let (lower, _) = reasons in
      UseOp
        {
          loc = loc_of_reason lower;
          features = [text "read-only arrays cannot be written to"];
          use_op;
        }
    | EUnionSpeculationFailed { use_op; reason; reason_op = _; branches } ->
      Speculation { loc = loc_of_reason reason; use_op; branches }
    | ESpeculationAmbiguous
        { reason = _; prev_case = (prev_i, prev_case); case = (i, case); cases = case_rs } ->
      Friendly.(
        let prev_case_r =
          mk_reason (RCustom ("case " ^ string_of_int (prev_i + 1))) (loc_of_reason prev_case)
        in
        let case_r = mk_reason (RCustom ("case " ^ string_of_int (i + 1))) (loc_of_reason case) in
        let features =
          [
            text "Could not decide which case to select, since ";
            ref prev_case_r;
            text " ";
            text "may work but if it doesn't ";
            ref case_r;
            text " looks promising ";
            text "too. To fix add a type annotation ";
          ]
          @ conjunction_concat
              ~conjunction:"or"
              (Core_list.map
                 ~f:(fun case_r ->
                   let text = "to " ^ string_of_desc (desc_of_reason case_r) in
                   [ref (mk_reason (RCustom text) (loc_of_reason case_r))])
                 case_rs)
          @ [text "."]
        in
        Normal { features })
    | EIncompatibleWithExact (reasons, use_op) ->
      let (lower, upper) = reasons in
      UseOp
        {
          loc = loc_of_reason lower;
          features = [text "inexact "; ref lower; text " is incompatible with exact "; ref upper];
          use_op;
        }
    | EUnsupportedExact (_, lower) ->
      Normal { features = [text "Cannot create exact type from "; ref lower; text "."] }
    | EIdxArity _ ->
      let features =
        [
          text "Cannot call ";
          code "idx(...)";
          text " because only exactly two ";
          text "arguments are allowed.";
        ]
      in
      Normal { features }
    | EIdxUse1 _ ->
      let features =
        [
          text "Cannot call ";
          code "idx(...)";
          text " because the callback ";
          text "argument must not be annotated.";
        ]
      in
      Normal { features }
    | EIdxUse2 _ ->
      let features =
        [
          text "Cannot call ";
          code "idx(...)";
          text " because the callback must ";
          text "only access properties on the callback parameter.";
        ]
      in
      Normal { features }
    | EUnexpectedThisType _ ->
      Normal { features = [text "Unexpected use of "; code "this"; text " type."] }
    | EPropertyTypeAnnot _ ->
      let features =
        [
          text "Cannot use ";
          code "$PropertyType";
          text " because the second ";
          text "type argument must be a string literal.";
        ]
      in
      Normal { features }
    | EExportsAnnot _ ->
      let features =
        [
          text "Cannot use ";
          code "$Exports";
          text " because the first type ";
          text "argument must be a string literal.";
        ]
      in
      Normal { features }
    | ECharSetAnnot _ ->
      let features =
        [
          text "Cannot use ";
          code "$CharSet";
          text " because the first type ";
          text "argument must be a string literal.";
        ]
      in
      Normal { features }
    | EInvalidCharSet { invalid = (invalid_reason, invalid_chars); valid = valid_reason; use_op }
      ->
      let valid_reason =
        mk_reason (desc_of_reason valid_reason) (def_loc_of_reason valid_reason)
      in
      let invalids =
        InvalidCharSetSet.fold
          (fun c acc ->
            match c with
            | InvalidChar c -> [code (String.make 1 c); text " is not a member of the set"] :: acc
            | DuplicateChar c -> [code (String.make 1 c); text " is duplicated"] :: acc)
          invalid_chars
          []
        |> List.rev
      in
      UseOp
        {
          loc = loc_of_reason invalid_reason;
          features =
            [ref invalid_reason; text " is incompatible with "; ref valid_reason; text " since "]
            @ Friendly.conjunction_concat ~conjunction:"and" invalids;
          use_op;
        }
    | EUnsupportedKeyInObjectType _ ->
      Normal { features = [text "Unsupported key in object type."] }
    | EPredAnnot _ ->
      let features =
        [
          text "Cannot use ";
          code "$Pred";
          text " because the first ";
          text "type argument must be a number literal.";
        ]
      in
      Normal { features }
    | ERefineAnnot _ ->
      let features =
        [
          text "Cannot use ";
          code "$Refine";
          text " because the third ";
          text "type argument must be a number literal.";
        ]
      in
      Normal { features }
    | ETrustedAnnot _ ->
      Normal { features = [text "Not a valid type to mark as "; code "$Trusted"; text "."] }
    | EPrivateAnnot _ ->
      Normal { features = [text "Not a valid type to mark as "; code "$Private"; text "."] }
    | EUnexpectedTypeof _ ->
      Normal { features = [code "typeof"; text " can only be used to get the type of variables."] }
    | EFunPredCustom ((a, b), msg) ->
      Normal { features = [ref a; text ". "; text msg; text " "; ref b; text "."] }
    | EIncompatibleWithShape (lower, upper, use_op) ->
      UseOp
        {
          loc = loc_of_reason lower;
          features =
            [ref lower; text " is incompatible with "; code "$Shape"; text " of "; ref upper];
          use_op;
        }
    | EInternal (_, internal_error) ->
      let msg = string_of_internal_error internal_error in
      Normal { features = [text (spf "Internal error: %s" msg)] }
    | EUnsupportedSyntax (_, unsupported_syntax) ->
      let features =
        match unsupported_syntax with
        | ComprehensionExpression
        | GeneratorExpression
        | MetaPropertyExpression ->
          [text "Not supported."]
        | ObjectPropertyLiteralNonString ->
          [text "Non-string literal property keys not supported."]
        | ObjectPropertyGetSet -> [text "Get/set properties not yet supported."]
        | ObjectPropertyComputedGetSet ->
          [text "Computed getters and setters are not yet supported."]
        | InvariantSpreadArgument ->
          [text "Unsupported arguments in call to "; code "invariant"; text "."]
        | ClassPropertyLiteral -> [text "Literal properties not yet supported."]
        | ClassPropertyComputed -> [text "Computed property keys not supported."]
        | ReactCreateClassPropertyNonInit ->
          [text "Unsupported property specification in "; code "createClass"; text "."]
        | RequireDynamicArgument ->
          [text "The parameter passed to "; code "require"; text " must be a string literal."]
        | ImportDynamicArgument ->
          [text "The parameter passed to "; code "import"; text " must be a string literal."]
        | RequireLazyDynamicArgument ->
          [
            text "The first argument to ";
            code "requireLazy";
            text " must be an ";
            text "array literal of string literals and the second argument must ";
            text "be a callback.";
          ]
        | CatchParameterAnnotation ->
          [text "Type annotations for catch parameters are not yet supported."]
        | CatchParameterDeclaration -> [text "Unsupported catch parameter declaration."]
        | DestructuringObjectPropertyLiteralNonString ->
          [text "Unsupported non-string literal object property in destructuring."]
        | DestructuringExpressionPattern ->
          [text "Unsupported expression pattern in destructuring."]
        | PredicateDeclarationForImplementation ->
          [text "Cannot declare predicate when a function body is present."]
        | PredicateDeclarationWithoutExpression ->
          [text "Predicate function declarations need to declare a "; text "predicate expression."]
        | PredicateDeclarationAnonymousParameters ->
          [
            text "Predicate function declarations cannot use anonymous ";
            text "function parameters.";
          ]
        | PredicateInvalidBody ->
          [
            text "Invalid body for predicate function. Expected a simple return ";
            text "statement as body.";
          ]
        | PredicateFunctionAbstractReturnType ->
          [
            text "The return type of a predicate function cannot contain a generic type. ";
            text "The function predicate will be ignored here.";
          ]
        | PredicateVoidReturn -> [text "Predicate functions need to return non-void."]
        | MultipleIndexers -> [text "Multiple indexers are not supported."]
        | MultipleProtos -> [text "Multiple prototypes specified."]
        | ExplicitCallAfterProto -> [text "Unexpected call property after explicit prototype."]
        | ExplicitProtoAfterCall -> [text "Unexpected prototype after call property."]
        | SpreadArgument -> [text "A spread argument is unsupported here."]
        | IllegalName -> [text "Illegal name."]
        | UnsupportedInternalSlot { name; static = false } ->
          [text "Unsupported internal slot "; code name; text "."]
        | UnsupportedInternalSlot { name; static = true } ->
          [text "Unsupported static internal slot "; code name; text "."]
      in
      Normal { features }
    | EUseArrayLiteral _ ->
      Normal
        { features = [text "Use an array literal instead of "; code "new Array(...)"; text "."] }
    | EMissingAnnotation (reason, _) ->
      let default = [text "Missing type annotation for "; desc reason; text "."] in
      let features =
        match desc_of_reason reason with
        | RTypeParam (_, (RImplicitInstantiation, _), _) ->
          [
            text "Please use a concrete type annotation instead of ";
            code "_";
            text " in this position.";
          ]
        | RTypeParam (_, (reason_op_desc, reason_op_loc), (reason_tapp_desc, reason_tapp_loc)) ->
          let reason_op = mk_reason reason_op_desc reason_op_loc in
          let reason_tapp = mk_reason reason_tapp_desc reason_tapp_loc in
          default
          @ [
              text " ";
              desc reason;
              text " is a type parameter declared in ";
              ref reason_tapp;
              text " and was implicitly instantiated at ";
              ref reason_op;
              text ".";
            ]
        | _ -> default
      in
      (* We don't collect trace info in the assert_ground_visitor because traces
       * represent tests of lower bounds to upper bounds, and the assert_ground
       * visitor is just visiting types. Instead, we collect a list of types we
       * visited to get to the missing annotation error and report that as the
       * trace *)
      Normal { features }
    | EBindingError (binding_error, _, x, entry) ->
      let desc =
        if x = internal_name "this" then
          RThis
        else if x = internal_name "super" then
          RSuper
        else
          RIdentifier x
      in
      (* We can call to_loc here because reaching this point requires that everything else
        in the error message is concretized already; making Scopes polymorphic is not a good idea *)
      let x = mk_reason desc (Scope.Entry.entry_loc entry |> ALoc.to_loc_exn) in
      let features =
        match binding_error with
        | ENameAlreadyBound ->
          [text "Cannot declare "; ref x; text " because the name is already bound."]
        | EReferencedBeforeDeclaration ->
          if desc = RThis || desc = RSuper then
            [
              text "Must call ";
              code "super";
              text " before accessing ";
              ref x;
              text " in a derived constructor.";
            ]
          else
            [
              text "Cannot use variable ";
              ref x;
              text " because the declaration ";
              text "either comes later or was skipped.";
            ]
        | ETypeInValuePosition
        | ETypeAliasInValuePosition ->
          [text "Cannot reference type "; ref x; text " from a value position."]
        | EConstReassigned
        | EConstParamReassigned ->
          [text "Cannot reassign constant "; ref x; text "."]
        | EImportReassigned -> [text "Cannot reassign import "; ref x; text "."]
        | EEnumReassigned -> [text "Cannot reassign enum "; ref x; text "."]
      in
      Normal { features }
    | ERecursionLimit _ -> Normal { features = [text "*** Recursion limit exceeded ***"] }
    | EModuleOutsideRoot (_, package_relative_to_root) ->
      let features =
        [
          text "This module resolves to ";
          code package_relative_to_root;
          text " which ";
          text "is outside both your root directory and all of the entries in the ";
          code "[include]";
          text " section of your ";
          code ".flowconfig";
          text ". ";
          text "You should either add this directory to the ";
          code "[include]";
          text " ";
          text "section of your ";
          code ".flowconfig";
          text ", move your ";
          code ".flowconfig";
          text " file higher in the project directory tree, or ";
          text "move this package under your Flow root directory.";
        ]
      in
      Normal { features }
    | EMalformedPackageJson (_, error) -> Normal { features = [text error] }
    | EExperimentalDecorators _ ->
      let features =
        [
          text "Experimental decorator usage. Decorators are an early stage ";
          text "proposal that may change. Additionally, Flow does not account for ";
          text "the type implications of decorators at this time.";
        ]
      in
      Normal { features }
    | EExperimentalClassProperties (_, static) ->
      let (config_name, config_key) =
        if static then
          ("class static field", "class_static_fields")
        else
          ("class instance field", "class_instance_fields")
      in
      let features =
        [
          text ("Experimental " ^ config_name ^ " usage. ");
          text (String.capitalize_ascii config_name ^ "s are an active early stage ");
          text "feature proposal that may change. You may opt-in to using them ";
          text "anyway in Flow by putting ";
          code ("esproposal." ^ config_key ^ "=enable");
          text " ";
          text "into the ";
          code "[options]";
          text " section of your ";
          code ".flowconfig";
          text ".";
        ]
      in
      Normal { features }
    | EUnsafeGetSet _ ->
      let features =
        [
          text "Potentially unsafe get/set usage. Getters and setters with side ";
          text "effects are potentially unsafe and so disabled by default. You may ";
          text "opt-in to using them anyway by putting ";
          code "unsafe.enable_getters_and_setters";
          text " into the ";
          code "[options]";
          text " section of your ";
          code ".flowconfig";
          text ".";
        ]
      in
      Normal { features }
    | EUninitializedInstanceProperty (_loc, err) ->
      let open Lints in
      let features =
        match err with
        | PropertyNotDefinitelyInitialized ->
          [
            text "Class property not definitely initialized in the constructor. ";
            text "Can you add an assignment to the property declaration?";
          ]
        | ReadFromUninitializedProperty ->
          [
            text "It is unsafe to read from a class property before it is ";
            text "definitely initialized.";
          ]
        | MethodCallBeforeEverythingInitialized ->
          [
            text "It is unsafe to call a method in the constructor before all ";
            text "class properties are definitely initialized.";
          ]
        | PropertyFunctionCallBeforeEverythingInitialized ->
          [
            text "It is unsafe to call a property function in the constructor ";
            text "before all class properties are definitely initialized.";
          ]
        | ThisBeforeEverythingInitialized ->
          [
            text "It is unsafe to use ";
            code "this";
            text " in the constructor ";
            text "before all class properties are definitely initialized.";
          ]
      in
      Normal { features }
    | EExperimentalExportStarAs _ ->
      let features =
        [
          text "Experimental ";
          code "export * as";
          text " usage. ";
          code "export * as";
          text " is an active early stage feature propsal that ";
          text "may change. You may opt-in to using it anyway by putting ";
          code "esproposal.export_star_as=enable";
          text " into the ";
          code "[options]";
          text " section of your ";
          code ".flowconfig";
          text ".";
        ]
      in
      Normal { features }
    | EExperimentalEnums _ ->
      let features =
        [
          text "Experimental ";
          code "enum";
          text " usage. ";
          text "You may opt-in to using enums by putting ";
          code "experimental.enums=true";
          text " into the ";
          code "[options]";
          text " section of your ";
          code ".flowconfig";
          text ".";
        ]
      in
      Normal { features }
    | EIndeterminateModuleType _ ->
      let features =
        [
          text "Unable to determine module type (CommonJS vs ES) if both an export ";
          text "statement and ";
          code "module.exports";
          text " are used in the ";
          text "same module!";
        ]
      in
      Normal { features }
    | EBadExportPosition _ ->
      Normal { features = [text "Exports can only appear at the top level"] }
    | EBadExportContext (name, _) ->
      Normal
        {
          features =
            [code name; text " may only be used as part of a legal top level export statement"];
        }
    | EUnexpectedTemporaryBaseType _ ->
      Normal
        {
          features =
            [text "The type argument of a temporary base type must be a compatible literal type"];
        }
    | ECannotDelete (_, expr) ->
      let features =
        [
          text "Cannot delete ";
          ref expr;
          text " because only member expressions and variables can be deleted.";
        ]
      in
      Normal { features }
    | ESignatureVerification sve ->
      Signature_error.(
        let features =
          match sve with
          | ExpectedSort (sort, x, _) ->
            [code x; text (spf " is not a %s." (Signature_builder_kind.Sort.to_string sort))]
          | ExpectedAnnotation (_, sort) ->
            [text (spf "Missing type annotation at %s:" (Expected_annotation_sort.to_string sort))]
          | InvalidTypeParamUse _ -> [text "Invalid use of type parameter:"]
          | UnexpectedObjectKey _ -> [text "Expected simple key in object:"]
          | UnexpectedObjectSpread _ -> [text "Unexpected spread in object:"]
          | UnexpectedArraySpread _ -> [text "Unexpected spread in array:"]
          | UnexpectedArrayHole _ -> [text "Unexpected array hole:"]
          | EmptyArray _ ->
            [
              text "Cannot determine the element type of an empty array. ";
              text
                "Please provide an annotation, e.g., by adding a type cast around this expression.";
            ]
          | EmptyObject _ ->
            [
              text "Cannot determine types of initialized properties of an empty object. ";
              text
                "Please provide an annotation, e.g., by adding a type cast around this expression.";
            ]
          | UnexpectedExpression (_, esort) ->
            [
              text
                (spf
                   "Cannot determine the type of this %s. "
                   (Flow_ast_utils.ExpressionSort.to_string esort));
              text
                "Please provide an annotation, e.g., by adding a type cast around this expression.";
            ]
          | SketchyToplevelDef _ -> [text "Unexpected toplevel definition that needs hoisting:"]
          | UnsupportedPredicateExpression _ ->
            [text "Unsupported kind of expression in predicate function:"]
          | TODO (msg, _) ->
            [text (spf "TODO: %s is not supported yet, try using a type cast." msg)]
        in
        let features =
          text "Failed to build a typed interface for this module. "
          :: text "The exports of this module must be annotated with types. "
          :: features
        in
        Normal { features })
    | EUnreachable _ -> Normal { features = [text "Unreachable code."] }
    | EInvalidObjectKit { reason; reason_op = _; use_op } ->
      UseOp
        { loc = loc_of_reason reason; features = [ref reason; text " is not an object"]; use_op }
    | EInvalidTypeof (_, typename) ->
      let features =
        [
          text "Cannot compare the result of ";
          code "typeof";
          text " to string ";
          text "literal ";
          code typename;
          text " because it is not a valid ";
          code "typeof";
          text " return value.";
        ]
      in
      Normal { features }
    | EArithmeticOperand reason ->
      let features =
        [
          text "Cannot perform arithmetic operation because ";
          ref reason;
          text " ";
          text "is not a number.";
        ]
      in
      Normal { features }
    | EBinaryInLHS reason ->
      (* TODO: or symbol *)
      let features =
        [
          text "Cannot use ";
          code "in";
          text " because on the left-hand side, ";
          ref reason;
          text " must be a string or number.";
        ]
      in
      Normal { features }
    | EBinaryInRHS reason ->
      let features =
        [
          text "Cannot use ";
          code "in";
          text " because on the right-hand side, ";
          ref reason;
          text " must be an object or array.";
        ]
      in
      Normal { features }
    | EForInRHS reason ->
      let features =
        [
          text "Cannot iterate using a ";
          code "for...in";
          text " statement ";
          text "because ";
          ref reason;
          text " is not an object, null, or undefined.";
        ]
      in
      Normal { features }
    | EObjectComputedPropertyAccess (_, reason_prop) ->
      Normal
        { features = [text "Cannot access computed property using "; ref reason_prop; text "."] }
    | EObjectComputedPropertyAssign (_, reason_prop) ->
      Normal
        { features = [text "Cannot assign computed property using "; ref reason_prop; text "."] }
    | EInvalidLHSInAssignment _ ->
      Normal { features = [text "Invalid left-hand side in assignment expression."] }
    | EIncompatibleWithUseOp (reason_lower, reason_upper, use_op) ->
      Incompatible { reason_lower; reason_upper; use_op }
    | ETrustIncompatibleWithUseOp (reason_lower, reason_upper, use_op) ->
      IncompatibleTrust { reason_lower; reason_upper; use_op }
    | EUnsupportedImplements reason ->
      Normal
        {
          features =
            [text "Cannot implement "; desc reason; text " because it is not an interface."];
        }
    | ENotAReactComponent { reason; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason;
          features = [ref reason; text " is not a React component"];
          use_op;
        }
    | EInvalidReactConfigType { reason; use_op } ->
      UseOp
        {
          loc = loc_of_reason reason;
          features = [ref reason; text " cannot calculate config"];
          use_op;
        }
    | EInvalidReactPropType { reason; use_op; tool } ->
      React.(
        React.SimplifyPropType.(
          let is_not_prop_type = "is not a React propType" in
          let msg =
            match tool with
            | ArrayOf -> is_not_prop_type
            | InstanceOf -> "is not a class"
            | ObjectOf -> is_not_prop_type
            | OneOf ResolveArray -> "is not an array"
            | OneOf (ResolveElem _) -> "is not a literal"
            | OneOfType ResolveArray -> "is not an array"
            | OneOfType (ResolveElem _) -> is_not_prop_type
            | Shape ResolveObject -> "is not an object"
            | Shape (ResolveDict _) -> is_not_prop_type
            | Shape (ResolveProp _) -> is_not_prop_type
          in
          UseOp { loc = loc_of_reason reason; features = [ref reason; text (" " ^ msg)]; use_op }))
    | EInvalidReactCreateClass { reason; use_op; tool } ->
      React.(
        React.CreateClass.(
          let is_not_prop_type = "is not a React propType" in
          let msg =
            match tool with
            | Spec _ -> "is not an exact object"
            | Mixins _ -> "is not a tuple"
            | Statics _ -> "is not an object"
            | PropTypes (_, ResolveObject) -> "is not an object"
            | PropTypes (_, ResolveDict _) -> is_not_prop_type
            | PropTypes (_, ResolveProp _) -> is_not_prop_type
            | DefaultProps _ -> "is not an object"
            | InitialState _ -> "is not an object or null"
          in
          UseOp { loc = loc_of_reason reason; features = [ref reason; text (" " ^ msg)]; use_op }))
    | EReactElementFunArity (_, fn, n) ->
      let features =
        [
          text "Cannot call ";
          code ("React." ^ fn);
          text " ";
          text
            (spf
               "without at least %d argument%s."
               n
               ( if n == 1 then
                 ""
               else
                 "s" ));
        ]
      in
      Normal { features }
    | EFunctionCallExtraArg (unused_reason, def_reason, param_count, use_op) ->
      let msg =
        match param_count with
        | 0 -> "no arguments are expected by"
        | 1 -> "no more than 1 argument is expected by"
        | n -> spf "no more than %d arguments are expected by" n
      in
      UseOp
        {
          loc = loc_of_reason unused_reason;
          features = [text msg; text " "; ref def_reason];
          use_op;
        }
    | EUnsupportedSetProto _ ->
      Normal { features = [text "Mutating this prototype is unsupported."] }
    | EDuplicateModuleProvider { module_name; provider; _ } ->
      let features =
        [
          text "Duplicate module provider for ";
          code module_name;
          text ". Change ";
          text "either this module provider or the ";
          ref (mk_reason (RCustom "current module provider") provider);
          text ".";
        ]
      in
      Normal { features }
    | EParseError (_, parse_error) ->
      Normal { features = Friendly.message_of_string (Parse_error.PP.error parse_error) }
    | EDocblockError (_, err) ->
      let features =
        match err with
        | MultipleFlowAttributes ->
          [
            text "Unexpected ";
            code "@flow";
            text " declaration. Only one per ";
            text "file is allowed.";
          ]
        | MultipleProvidesModuleAttributes ->
          [
            text "Unexpected ";
            code "@providesModule";
            text " declaration. ";
            text "Only one per file is allowed.";
          ]
        | MultipleJSXAttributes ->
          [
            text "Unexpected ";
            code "@jsx";
            text " declaration. Only one per ";
            text "file is allowed.";
          ]
        | InvalidJSXAttribute first_error ->
          [
            text "Invalid ";
            code "@jsx";
            text " declaration. Should have the form ";
            code "@jsx LeftHandSideExpression";
            text " with no spaces.";
          ]
          @
          (match first_error with
          | None -> []
          | Some first_error -> [text (spf " Parse error: %s." first_error)])
      in
      Normal { features }
    | EImplicitInexactObject _ ->
      let features =
        [
          text "Please add ";
          code "...";
          text " to the end of the list of ";
          text "properties to express an inexact object type.";
        ]
      in
      Normal { features }
    | EUntypedTypeImport (_, module_name) ->
      let features =
        [
          text "Importing a type from an untyped module makes it ";
          code "any";
          text " ";
          text "and is not safe! Did you mean to add ";
          code "// @flow";
          text " to ";
          text "the top of ";
          code module_name;
          text "?";
        ]
      in
      Normal { features }
    | EUntypedImport (_, module_name) ->
      let features =
        [
          text "Importing from an untyped module makes it ";
          code "any";
          text " ";
          text "and is not safe! Did you mean to add ";
          code "// @flow";
          text " ";
          text "to the top of ";
          code module_name;
          text "?";
        ]
      in
      Normal { features }
    | ENonstrictImport _ ->
      let features =
        [
          text "Dependencies of a ";
          code "@flow strict";
          text " module must ";
          text "also be ";
          code "@flow strict";
          text "!";
        ]
      in
      Normal { features }
    | EUnclearType _ ->
      let features =
        [
          text "Unclear type. Using ";
          code "any";
          text ", ";
          code "Object";
          text ", or ";
          code "Function";
          text " types is not safe!";
        ]
      in
      Normal { features }
    | EDeprecatedType _ ->
      Normal
        {
          features = [text "Deprecated type. Using "; code "*"; text " types is not recommended!"];
        }
    | EDeprecatedUtility (_, name) ->
      Normal
        {
          features =
            [text "Deprecated utility. Using "; code name; text " types is not recommended!"];
        }
    | EDynamicExport (reason, reason_exp) ->
      let features =
        [
          text "Dynamic ";
          ref reason;
          text " unsafely appears in exported ";
          ref reason_exp;
          text ". This can cause importing modules to lose type coverage!";
        ]
      in
      Normal { features }
    | EUnsafeGettersSetters _ ->
      Normal { features = [text "Getters and setters can have side effects and are unsafe."] }
    | EUnusedSuppression _ -> Normal { features = [text "Unused suppression comment."] }
    | ELintSetting (_, kind) ->
      let features =
        match kind with
        | LintSettings.Redundant_argument ->
          [text "Redundant argument. This argument doesn't change any lint settings."]
        | LintSettings.Overwritten_argument ->
          [
            text "Redundant argument. The values set by this argument are ";
            text "overwritten later in this comment.";
          ]
        | LintSettings.Naked_comment ->
          [text "Malformed lint rule. At least one argument is required."]
        | LintSettings.Nonexistent_rule ->
          [
            text "Nonexistent/misspelled lint rule. Perhaps you have a ";
            text "missing/extra ";
            code ",";
            text "?";
          ]
        | LintSettings.Invalid_setting ->
          [text "Invalid setting. Valid settings are error, warn, and off."]
        | LintSettings.Malformed_argument ->
          [
            text "Malformed lint rule. Properly formed rules contain a single ";
            code ":";
            text " character. Perhaps you have a missing/extra ";
            code ",";
            text "?";
          ]
      in
      Normal { features }
    | ESketchyNullLint { kind = sketchy_kind; loc = _; falsy_loc; null_loc } ->
      let (type_str, value_str) =
        match sketchy_kind with
        | Lints.SketchyNullBool -> ("boolean", "false")
        | Lints.SketchyNullNumber -> ("number", "0")
        | Lints.SketchyNullString -> ("string", "an empty string")
        | Lints.SketchyNullMixed -> ("mixed", "false")
      in
      let features =
        [
          text "Sketchy null check on ";
          ref (mk_reason (RCustom type_str) falsy_loc);
          text " ";
          text "which is potentially ";
          text value_str;
          text ". Perhaps you meant to ";
          text "check for ";
          ref (mk_reason RNullOrVoid null_loc);
          text "?";
        ]
      in
      Normal { features }
    | ESketchyNumberLint (_, reason) ->
      let features =
        [
          text "Avoid using ";
          code "&&";
          text " to check the value of ";
          ref reason;
          text ". ";
          text "Consider handling falsy values (0 and NaN) by using a conditional to choose an ";
          text "explicit default instead.";
        ]
      in
      Normal { features }
    | EInvalidPrototype reason ->
      Normal
        {
          features =
            [text "Cannot use "; ref reason; text " as a prototype. Expected an object or null."];
        }
    | EExperimentalOptionalChaining _ ->
      let features =
        [
          text "Experimental optional chaining (";
          code "?.";
          text ") usage. ";
          text "Optional chaining is an active early-stage feature proposal that ";
          text "may change. You may opt in to using it anyway by putting ";
          code "esproposal.optional_chaining=enable";
          text " into the ";
          code "[options]";
          text " section of your ";
          code ".flowconfig";
          text ".";
        ]
      in
      Normal { features }
    | EOptionalChainingMethods _ ->
      Normal
        {
          features =
            [text "Flow does not yet support method or property calls in optional chains."];
        }
    | EUnnecessaryOptionalChain (_, lhs_reason) ->
      let features =
        [
          text "This use of optional chaining (";
          code "?.";
          text ") is unnecessary because ";
          ref lhs_reason;
          text " cannot be nullish or because an earlier ";
          code "?.";
          text " will short-circuit the nullish case.";
        ]
      in
      Normal { features }
    | EUnnecessaryInvariant (_, reason) ->
      let features =
        [
          text "This use of `invariant` is unnecessary because ";
          ref reason;
          text " is always truthy.";
        ]
      in
      Normal { features }
    | EInexactSpread (reason, reason_op) ->
      let features =
        [
          text "Cannot determine the type of ";
          ref reason_op;
          text " because ";
          text "it contains a spread of inexact ";
          ref reason;
          text ". ";
          text "Being inexact, ";
          ref reason;
          text " might be missing the types of some properties that are being copied. ";
          text "Perhaps you could make it exact?";
        ]
      in
      Normal { features }
    | EBigIntNotYetSupported reason ->
      Normal { features = [text "BigInt "; ref reason; text " is not yet supported."] }
    | ENonArraySpread reason ->
      let features =
        [
          text "Cannot spread non-array iterable ";
          ref reason;
          text ". Use ";
          code "...Array.from(<iterable>)";
          text " instead.";
        ]
      in
      Normal { features }
    | ECannotSpreadInterface { spread_reason; interface_reason } ->
      let features =
        [
          text "Cannot determine a type for ";
          ref spread_reason;
          text ". ";
          ref interface_reason;
          text " cannot be spread because interfaces do not ";
          text "track the own-ness of their properties. Can you use an object type instead?";
        ]
      in
      Normal { features }
    | ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason } ->
      let features =
        [
          text "Cannot determine a type for ";
          ref spread_reason;
          text ". ";
          ref object_reason;
          text " cannot be spread because the indexer ";
          ref key_reason;
          text " may overwrite properties with explicit keys in a way that Flow cannot track. ";
          text "Can you spread ";
          ref object_reason;
          text " first or remove the indexer?";
        ]
      in
      Normal { features }
    | EUnableToSpread { spread_reason; object1_reason; object2_reason; propname; error_kind } ->
      let (error_reason, fix_suggestion) =
        match error_kind with
        | Inexact -> ("is inexact", [text " Can you make "; ref object2_reason; text " exact?"])
        | Indexer ->
          ( "has an indexer",
            [
              text " Can you remove the indexer in ";
              ref object2_reason;
              text " or make ";
              code propname;
              text " a required property?";
            ] )
      in
      let features =
        [
          text "Cannot determine a type for ";
          ref spread_reason;
          text ". ";
          ref object2_reason;
          text " ";
          text error_reason;
          text ", so it may contain ";
          code propname;
          text " with a type that conflicts with ";
          code propname;
          text "'s definition in ";
          ref object1_reason;
          text ".";
        ]
        @ fix_suggestion
      in
      Normal { features }
    | EInexactMayOverwriteIndexer { spread_reason; key_reason; value_reason; object2_reason } ->
      let features =
        [
          text "Cannot determine a type for ";
          ref spread_reason;
          text ". ";
          ref object2_reason;
          text " is inexact and may ";
          text "have a property key that conflicts with ";
          ref key_reason;
          text " or a property value that conflicts with ";
          ref value_reason;
          text ". Can you make ";
          ref object2_reason;
          text " exact?";
        ]
      in
      Normal { features }
    | EExponentialSpread { reason; reasons_for_operand1; reasons_for_operand2 } ->
      let format_reason_group reasons =
        match reasons with
        | (r, []) -> [ref r]
        | (r, rs) ->
          text "inferred union from "
          :: (rs |> List.map (fun r -> [ref r; text " | "]) |> List.flatten)
          @ [ref r]
      in
      let union_refs =
        let reasons_for_operand1 = format_reason_group reasons_for_operand1 in
        let reasons_for_operand2 = format_reason_group reasons_for_operand2 in
        reasons_for_operand1 @ [text " and "] @ reasons_for_operand2
      in
      let features =
        [
          text "Computing ";
          ref reason;
          text " may lead to an exponentially large number of cases to reason about because ";
        ]
        @ union_refs
        @ [
            text
              " are both unions. Please use at most one union type per spread to simplify reasoning about the spread result.";
            text
              " You may be able to get rid of a union by specifying a more general type that captures all of the branches of the union.";
          ]
      in
      Normal { features }
    | EComputedPropertyWithMultipleLowerBounds
        { computed_property_reason; new_lower_bound_reason; existing_lower_bound_reason } ->
      let features =
        [
          text "Cannot use ";
          ref computed_property_reason;
          text " as a computed property.";
          text
            " Computed properties may only be primitive literal values, but this one may be either ";
          ref existing_lower_bound_reason;
          text " or ";
          ref new_lower_bound_reason;
          text ". Can you add a literal type annotation to ";
          ref computed_property_reason;
          text "?";
          text
            " See https://flow.org/en/docs/types/literals/ for more information on literal types.";
        ]
      in
      Normal { features }
    | EComputedPropertyWithUnion { computed_property_reason; union_reason } ->
      let features =
        [
          text "Cannot use ";
          ref computed_property_reason;
          text " as a computed property.";
          text " Computed properties may only be primitive literal values, but ";
          ref union_reason;
          text " is a union. Can you add a literal type annotation to ";
          ref computed_property_reason;
          text "?";
          text
            " See https://flow.org/en/docs/types/literals/ for more information on literal types.";
        ]
      in
      Normal { features })

let is_lint_error = function
  | EUntypedTypeImport _
  | EUntypedImport _
  | ENonstrictImport _
  | EUnclearType _
  | EDeprecatedType _
  | EDeprecatedUtility _
  | EDynamicExport _
  | EUnsafeGettersSetters _
  | ESketchyNullLint _
  | ESketchyNumberLint _
  | EInexactSpread _
  | EBigIntNotYetSupported _
  | EUnnecessaryOptionalChain _
  | EUnnecessaryInvariant _
  | EImplicitInexactObject _
  | EUninitializedInstanceProperty _
  | ENonArraySpread _ ->
    true
  | _ -> false
