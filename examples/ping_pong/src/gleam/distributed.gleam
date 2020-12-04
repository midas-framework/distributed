import gleam/otp/supervisor
import gleam/io
// Other names entrypoint Node Interface
pub type Interface(t){
    Interface(check: String)
}

// pub fn loop(receive, public) {
//     let from = receive
//     process.reply(from, public)
//     loop(receive, public)
// }

pub fn start(x, _i: Interface(t), entry: t) {
    // process waits for a call.
    // replies with entry term
    todo
}

pub fn connect(_i: Interface(t)) -> t {
    // try _ = case net_kernel_connect(name) {
    //     nk.True -> Ok(Nil)
    //     nk.False -> Error(Nil)
    //     nk.Ignored -> Error(Nil)
    // }
    // // instead of raw self a reference at startup time to the pid
    // remote_send(atom.create_from_string("GLEAM"), name, Connect(raw_self))
    // // await the processes back
    // // unsafe coerce
    todo
}
