(* nicknames module for Augeas
 Author: Alessandro De Salvo <alessandro.desalvo@roma1.infn.it>

 Reference: man 5 nicknames

*)

module Nicknames =

   autoload xfm

(************************************************************************
 *                           USEFUL PRIMITIVES
 *************************************************************************)

let eol        = Util.eol
let comment    = Util.comment
let empty      = Util.empty
let dels       = Util.del_str
let tab        = Util.del_ws_tab

let word       = Rx.word

(************************************************************************
 *                               ENTRIES
 *************************************************************************)

let entry     = [ key word . tab . [ label "map" . store word ] . eol ]

(************************************************************************
 *                                LENS
 *************************************************************************)

let lns        = (comment|empty|entry) *

let filter     = incl "/var/yp/nicknames"
               . Util.stdexcl

let xfm        = transform lns filter
