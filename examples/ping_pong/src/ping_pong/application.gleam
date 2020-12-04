import gleam/otp/actor
import gleam/otp/supervisor.{ApplicationStartMode, ErlangStartResult}
import gleam/dynamic.{Dynamic}
import gleam/distributed.{Interface}
import ping_pong/pinger

import gleam/io

// TODO derive this key using erlang vsn for the module.
const interface = Interface("123")

fn init(children) {
  let next_pinger = distributed.connect(interface)

  children
  |> supervisor.add(supervisor.worker(actor.start(_, pinger.loop)))
  |> supervisor.add(supervisor.worker(distributed.start(_, interface, Nil)))
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
