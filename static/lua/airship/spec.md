## Inputs:

Channel Direction: off/on changes forward/backward,
Channel Speed: Analog signal from 0-14~ (may be lower) decides thrust speed, 15 will stop,
Channel Left Turn: when on and right turn channel off, turns left.
Channel Right Turn: when on and left turn channel off, turns right.
Channel Up: when on turns up ticker for height channel
Channel Down: when on turns down ticker for height channel

### Subchannels:

Channel Height: automatic, 0-15, see channels up & down, used for air burner signal to decide height

## Channel Frequencies:

Channel Direction: #1: andesite alloy, #2: shaft
Channel Speed: #1: redstone, #2: redstone
Channel Left Turn: N/A (not made)
Channel Right Turn: N/A (not made)
Channel Up: #1: redstone accumulator, #2: redstone link
Channel Down: #1: redstone link, #2: redstone accumulator

Channel Height: #1: redstone torch, #2: redstone
Channel Aux Direction: #1: shaft, #2: andesite alloy

-----------

so, to show some examples for the output for forward/backward logic:
W and S would control an internal number in the computer which would output something like this
```
 14: direction 0,    speed 14
 10: direction 0,    speed 10
  1: direction 0,    speed 1
  0: direction 0/15, speed 15 (which stops)
 -1: direction 15,   speed 1
-10: direction 15,   speed 10
-14: direction 15,   speed 14
```