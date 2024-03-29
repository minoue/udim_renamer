import os
import strutils
import nigui
import nigui/msgbox
import strformat

proc mariToMudbox(udim: string): string =

  var u = parseInt($udim[3])
  var v = parseInt($udim[1..2]) + 1
  if u == 0:
    u = 10
    v = v - 1
  return "_u$1_v$2".format($u, $v)

proc mariToZBrush(udim: string): string =

  var u = parseInt($udim[3])
  var v = parseInt($udim[1..2]) + 1
  if u == 0:
    u = 10
    v = v - 1
  u -= 1
  v -= 1
  return "_u$1_v$2".format($u, $v)

proc mudboxToMari(u: int, v: int): string =

  return $(1000 + u + (v * 10 - 10))

proc mudboxToZBrush(u: int, v: int): string =

  return "_u$1_v$2".format(u-1, v-1)

proc zbrushToMari(u: int, v:int): string =

  let u2 = u + 1
  let v2 = v + 1

  return $(1000 + u2 + (v2 * 10 - 10))

proc zbrushToMudbox(u: int, v: int): string =

  return "_u$1_v$2".format(u+1, v+1)

proc convertType(inputType, outputType, value: string): string =

  if inputType == "Mari":
    if outputType == "Mudbox":
      # Mari -> Mudbox
      return mariToMudbox(value)
    else:
      # Mari -> ZBrush
      return mariToZBrush(value)
  elif inputType == "Mudbox":
    var u = parseInt($split(value, '_')[^2][^1])
    var v = parseInt($split(value, '_')[^1][^1])

    if outputType == "Mari":
      # Mudbox -> Mari
      return mudboxToMari(u, v)
    else:
      # Mudbox -> ZBrush
      return mudboxToZBrush(u, v)
  else:
    var u = parseInt($split(value, '_')[^2][^1])
    var v = parseInt($split(value, '_')[^1][^1])
    if outputType == "Mari":
      # ZBrush -> Mari
      return zbrushToMari(u, v)
    else:
      # ZBrush -> Mudbox
      return zbrushToMudbox(u, v)


# GUI
app.init()

var window = newWindow()
window.title="UDIM renamer"

var mainContainer = newLayoutContainer(Layout_Vertical)

var topContainer = newLayoutContainer(Layout_Horizontal)
var typeContainer = newLayoutContainer(Layout_Horizontal)
var renameContainer = newLayoutContainer(Layout_Horizontal)

window.add(mainContainer)

var ColorDisabled = Color(red: 200, green: 200, blue: 200)
var ColorWhite = Color(red: 255, green: 255, blue: 255)

var openButton = newButton("Select Files ...")
openButton.widthMode=WidthMode_Expand
var clearButton = newButton("Clear list")
clearButton.widthMode=WidthMode_Expand
var fileListArea = newTextArea()
fileListArea.editable=false

clearButton.onClick=proc(event: ClickEvent) =
  fileListArea.text=""

var fromCombobox = newComboBox(@["Mudbox", "Mari", "ZBrush"])
fromCombobox.widthMode=WidthMode_Expand
var toCombobox = newComboBox(@["Mari", "Mudbox", "ZBrush"])
toCombobox.widthMode=WidthMode_Expand
var renameCheckbox = newCheckbox("Rename")
var renameField = newTextBox()
renameField.editable=false
renameField.setBackgroundColor(ColorDisabled)
var renameButton = newButton("Rename textures")
renameButton.widthMode = WidthMode_Expand

topContainer.add(openButton)
topContainer.add(clearButton)

typeContainer.add(newLabel("from: "))
typeContainer.add(fromCombobox)
typeContainer.add(newLabel("to: "))
typeContainer.add(toCombobox)

renameContainer.add(renameCheckbox)
renameContainer.add(renameField)

mainContainer.add(topContainer)
mainContainer.add(fileListArea)
mainContainer.add(typeContainer)
mainContainer.add(renameContainer)
mainContainer.add(renameButton)

openButton.onClick = proc(event: ClickEvent) =
  var dialog = newOpenFileDialog()
  dialog.title = "Select textures"
  dialog.multiple = true
  dialog.run()
  if dialog.files.len > 0:
    for file in dialog.files:
      fileListArea.addLine(file)

proc convertNames(textures_old: seq[string], fromType: string, toType: string): seq[string] =

  # output container for return
  var textures_new: seq[string] = @[]

  for tex in textures_old:
    if not fileExists(tex):
      continue

    let pathSplit = splitFile(tex)
    let name = pathSplit.name
    let dir = pathSplit.dir
    let ext = pathSplit.ext

    var uvValue: string
    var nameBody: string

    if fromType == "Mari":
      nameBody = name[0..^5]
      uvValue = name[^4..^1]
    else:
      nameBody = name[0..^7]
      uvValue = name[^6..^1]

    if endsWith(nameBody, "."):
      nameBody = nameBody.rsplit('.')[0]

    let newType = convertType(fromType, toType, uvValue)

    var newBody: string
    var newPath: string

    if renameCheckbox.checked():
      nameBody = renameField.text()

    if toType == "Mari":
      newBody = nameBody & "." & newType & ext
    else:
      newBody = nameBody & newType & ext

    newPath = joinPath(dir, newBody)

    textures_new.add(newPath)


  return textures_new


renameCheckbox.onClick=proc(event: ClickEvent) =
  if renameCheckbox.checked():
    renameField.editable=false
    renameField.setBackgroundColor(ColorDisabled)
  else:
    renameField.editable=true
    renameField.setBackgroundColor(ColorWhite)

renameButton.onClick=proc(event: ClickEvent) =

  let fromType = fromCombobox.value
  let toType = toCombobox.value
  if fromType == toType:
    window.alert("Input type and output type is same.\nChoose different texture types.")
    return

  let textAreaStr = fileListArea.text
  if textAreaStr == "":
    window.alert("No textures are loaded")
    return

  let textures_old = splitLines(textAreaStr)

  var textures_new: seq[string]

  try:
    textures_new = convertNames(textures_old, fromType, toType)
  except Exception:
    window.alert("Failed. Make sure setup is correct.")
    return

  var previewString: string = "Textures will be renamed as follows. \n\n"

  for i, x in textures_new:
    var oldName = splitPath(textures_old[i]).tail
    var newName = splitPath(x).tail
    previewString.add(fmt("{oldName} ---> {newName}  \n"))

  let res = window.msgBox(previewString, "Rename", "Ok", "Cancel")

  if res == 1:
    for i, x in textures_new:
      var oldName = textures_old[i]
      var newName = x
      moveFile(oldName, newName)
  
window.show()
app.run()
