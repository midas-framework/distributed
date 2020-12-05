import gleam/atom.{Atom}
import gleam/dynamic.{Dynamic}
import gleam/otp/actor
import gleam/otp/process.{Sender}
import gleam/otp/supervisor
import gleam/distributed/node.{Interface, Node}
import gleam/io

const entry_name = "gleam@distributed"

// Always returns True, raises badarg for failure cases
// https://erlang.org/doc/man/erlang.html#register-2
// This function is only used internally
external fn erl_register(Atom, process.Pid) -> Bool =
  "erlang" "register"

fn real_loop(receiver, entry) {
  let from = process.receive_forever(receiver)
  let from = dynamic.unsafe_coerce(from)
  actor.send(from, entry)
  real_loop(receiver, entry)
}

fn switch_to_bare(_: Nil, entry) {
  let receiver = process.bare_message_receiver()
  real_loop(receiver, entry)
  // Real loop never drops out to this point
  todo("NEVER")
}

pub fn start(_i: Interface(t), entry: t) {
  try sender = actor.start(entry, switch_to_bare)
  process.send(sender, Nil)
  let True =
    erl_register(atom.create_from_string(entry_name), process.pid(sender))
  Ok(sender)
}

pub external type NodeName

external fn net_kernel_connect(Atom) -> Dynamic =
  "net_kernel" "connect_node"

external fn self() -> NodeName =
  "erlang" "node"

external fn rpc_call(NodeName, Atom, Atom, List(Atom)) -> process.Pid =
  "rpc" "call"

fn node_whereis(node: NodeName, registered: String) {
  rpc_call(
    node,
    atom.create_from_string("erlang"),
    atom.create_from_string("whereis"),
    [atom.create_from_string(registered)],
  )
}

pub fn connect(_i: Interface(t), node) -> Result(t, Dynamic) {
  let node = atom.create_from_string(node)
  let true_atom = dynamic.from(atom.create_from_string("true"))
  try _ =
    case net_kernel_connect(node) {
      term if term == true_atom -> Ok(Nil)
      term -> Error(term)
    }
    |> io.debug()

  let node: NodeName = dynamic.unsafe_coerce(dynamic.from(node))
  try _ = case node == self() {
    False -> Ok(Nil)
    True -> Error(dynamic.from("connected to self"))
  }

  let remote_entry_process = node_whereis(node, entry_name)
  let remote = process.new_bare_sender(remote_entry_process)

  // Note actor.call throws runtime error for failure to get a response
  assert x = actor.call(remote, fn(from) { from }, 5000)
  Ok(dynamic.unsafe_coerce(x))
}
