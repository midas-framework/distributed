# ping_pong

**All the code is in the example ping pong project**

## Approach

To accept connection
1. create a Node interface, this is parameterised by type.
2. Start a node process with a bunch of data (pids or simple data) that should be passed to connecting nodes.
3. connect to a node and use the returned data

```rust
const interface = node.Interface("uuid")

pub fn run() {
  node.start(interface, "hello")
  assert Ok(data) = node.connect(interface, "node@127.0.0.1")
  // This line would cause a compilation error because the interface type is checked at compile time.
  // data + 1
}
```
