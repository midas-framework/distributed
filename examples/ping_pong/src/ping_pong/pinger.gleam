import gleam/otp/actor.{Continue}
import gleam/otp/process
import gleam/io
import gleam/string

pub type Greet {
  Greet(process.Sender(String), String)
}

pub fn loop(message, _) {
  let Greet(from, greeting) = message
  io.debug(greeting)
  actor.send(from, string.reverse(greeting))
  Continue(Nil)
}
