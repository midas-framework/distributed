import gleam/otp/actor
import gleam/otp/process
import gleam/otp/supervisor.{ApplicationStartMode, ErlangStartResult}
import gleam/dynamic.{Dynamic}
import gleam/distributed/node.{Interface}
import gleam/distributed
import ping_pong/pinger.{Greet}
import gleam/io

// TODO derive this key using erlang vsn for the module.
const interface = Interface("123")

fn init(children) {
  case distributed.connect(interface, "n1@127.0.0.1") {
    Ok(next_pinger) -> {
      let response = actor.call(next_pinger, Greet(_, "hello"), 5000)
      io.debug(response)
    }
    Error(_) -> io.debug("No connection")
  }

  children
  |> supervisor.add(
    supervisor.worker(actor.start(_, pinger.loop))
    |> supervisor.returning(fn(_: Nil, pid) { pid }),
  )
  |> supervisor.add(supervisor.worker(distributed.start(interface, _)))
}

pub fn start(
  _mode: ApplicationStartMode,
  _args: List(Dynamic),
) -> ErlangStartResult {
  init
  |> supervisor.start
  |> supervisor.to_erlang_start_result
}

pub fn stop(_state: Dynamic) {
  supervisor.application_stopped()
}
