import strutils


proc extractUV(tile: string): (int, int) =
  var u_str = $split(tile, "_")[1]
  var v_str = $split(tile, "_")[2]
  removePrefix(u_str, 'u')
  removePrefix(v_str, 'v')
  let u = parseInt(u_str)
  let v = parseInt(v_str)

  return (u, v)


proc mariToMudbox*(udim: string): string =

  var u = parseInt($udim[3])
  var v = parseInt($udim[1..2]) + 1
  if u == 0:
    u = 10
    v = v - 1
  return "_u$1_v$2".format($u, $v)

proc mariToZBrush*(udim: string): string =

  var u = parseInt($udim[3])
  var v = parseInt($udim[1..2]) + 1
  if u == 0:
    u = 10
    v = v - 1
  u -= 1
  v -= 1
  return "_u$1_v$2".format($u, $v)

proc mudboxToMari*(tile: string): string =

  let (u, v) = extractUV(tile)

  let udim = $(1000 + u + (v * 10 - 10))
  return udim

proc mudboxToZBrush*(tile: string): string =

  let (u, v) = extractUV(tile)

  var zbrush_tile = "_u$1_v$2".format(u-1, v-1)
  return zbrush_tile

proc zbrushToMari*(tile: string): string =

  let (u, v) = extractUV(tile)

  let u2 = u + 1
  let v2 = v + 1

  let udim = $(1000 + u2 + (v2 * 10 - 10))
  return udim

proc zbrushToMudbox*(tile: string): string =

  let (u, v) = extractUV(tile)

  var mudbox_tile = "_u$1_v$2".format(u+1, v+1)
  return mudbox_tile
