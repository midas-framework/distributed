import gleam/atom
import gleam/dynamic

// An atom that represents the name of the node
pub external type Node

// A type that is used to check messages between nodes after connection.
// The check value is used to perform a runtime check at connection time, to check the software is at the same version
// It would be nice to automatically derive the value of the runtime check from a hash of the type signatures.
// A good proxy is to use the module vsn information erlang.org/doc/reference_manual/modules.html
pub type Interface(t) {
  Interface(check: String)
}

// No guarantee that this node exists
pub fn from_name(name) -> Node {
  name
  |> atom.create_from_string()
  |> dynamic.from()
  |> dynamic.unsafe_coerce()
}
