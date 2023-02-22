#[
  @see
    - [tasks](https://nim-lang.org/docs/tasks.html)
    - https://github.com/status-im/nim-chronos/
    - https://nim-lang.org/docs/asyncdispatch.html
    - https://nim-lang.org/docs/asyncfutures.html
    - https://nim-lang.org/docs/asyncfile.html
    - https://nim-lang.org/docs/asyncstreams.html
    - https://nim-lang.org/docs/channels_builtin.html (system)
    - https://nim-lang.org/docs/coro.html
    - https://nim-lang.org/docs/manual_experimental.html#parallel-amp-spawn
    - https://nim-lang.org/docs/streams.html # probably should be in os/io
    - https://nim-lang.org/docs/threadpool.html
    - https://nim-lang.org/docs/threads.html (system)
    - https://peterme.net/asynchronous-programming-in-nim.html
    - https://nim-lang.org/docs/system.html#%7C%7C.i%2CS%2CT%2Cstaticstring parallel loop operator
    - [fusion pools](https://nim-lang.github.io/fusion/src/fusion/pools.html)

  thread related stuff requires --threads:on

  modules
  - threadpool: abstraction over lower level system thread fnality

  best practices
  - procs used with threads should (but dont need to) have {.thread.} pragma
  - vars local to threads should use {.threadvar.}

]#

import std/[threadpool, asyncdispatch]

echo "############################ threads"
# basic cpu intensive calculation
proc ekothis(i: int): void {.thread.} =
  echo "i am thread ", $i
var threads: array[10, Thread[int]]

# without threadpool
for i in threads.low..threads.high:
  createThread(threads[i], ekothis, i)
joinThreads(threads)

# with spawn
for i in ord(threads.low)..ord(threads.high):
  spawn (i + 10).ekothis
sync()


echo "############################ channels for comms between threads"
var
  chizzle: Channel[string] # a queue for strings
  gf: Thread[void]
  bf: Thread[void]
# send will deep copy its arguments
proc textMsg: void {.thread.} = chizzle.send("we need to talk")
proc ignoreMsg: void {.thread.} = echo "...ignoring phone beeping, i know its my gf saying some stoopid shiz like " & $chizzle.recv()

# without threadpool
open chizzle # unlimited queue size, defaults to 0
createThread gf, textMsg
bf.createThread ignoreMsg
joinThreads gf, bf

# with spawn
# only 2 items allowed in queue at any given time
# subsequent send calls will be blocked (use trySend to guard against this)
open chizzle, 2
spawn textMsg()
spawn ignoreMsg()
sync()

echo "############################ channels: non blocking"
# let maybe = chizzel.tryRecv
# if maybe.dataAvailable: echo maybe.msg
echo "############################ channels: blocked msgs"
# if not chizzle.trySend("this msg"): then try again later maybe

echo "############################ async"
# basic i/o intensive operation
# an async proc
proc laterGater(s: string): Future[void] {.async.} =
  for i in 1..10:
    await sleepAsync(10) # ms
    echo "iteration ", i, " for string ", s

let
  seeya = laterGater("see ya later aligator")
  afterwhile = laterGater("after while crocodile")
waitFor seeya and afterwhile
# also runForever
