import os
import strutils
import options
import nigui
import nigui/msgbox
import strformat
import udim_convert
from sequtils import zip


proc convertType(inputType, outputType, value: string): string =

  if inputType == "Mari":
    if outputType == "Mudbox":
      return mariToMudbox(value)
    else:
      return mariToZBrush(value)
  elif inputType == "Mudbox":
    if outputType == "Mari":
      return mudboxToMari(value)
    else:
      return mudboxToZBrush(value)
  else:
    if outputType == "Mari":
      return zbrushToMari(value)
    else:
      return zbrushToMudbox(value)


# GUI
app.init()

var window = newWindow()
window.title="UDIM renamer"

var mainContainer = newLayoutContainer(Layout_Vertical)

var topContainer = newLayoutContainer(Layout_Horizontal)
var listContainer = newLayoutContainer(Layout_Horizontal)
var typeContainer = newLayoutContainer(Layout_Horizontal)
var renameContainer = newLayoutContainer(Layout_Horizontal)

window.add(mainContainer)

var ColorDisabled = Color(red: 200, green: 200, blue: 200)
var ColorWhite = Color(red: 255, green: 255, blue: 255)

var openButton = newButton("Select Files ...")
openButton.widthMode=WidthMode_Expand
var clearButton = newButton("Clear list")
clearButton.widthMode=WidthMode_Expand

var fileListAreaBefore = newTextArea()
fileListAreaBefore.editable=false
var fileListAreaAfter = newTextArea()
fileListAreaAfter.editable=false

clearButton.onClick=proc(event: ClickEvent) =
  fileListAreaBefore.text=""
  fileListAreaAfter.text=""

var fromCombobox = newComboBox(@["Mudbox", "Mari", "ZBrush"])
fromCombobox.widthMode=WidthMode_Expand
var toCombobox = newComboBox(@["Mari", "Mudbox", "ZBrush"])
toCombobox.widthMode=WidthMode_Expand
var renameCheckbox = newCheckbox("Rename")
var renameField = newTextBox()
var renameButton = newButton("Rename textures")
renameButton.widthMode = WidthMode_Expand

topContainer.add(openButton)
topContainer.add(clearButton)

listContainer.add(fileListAreaBefore)
listContainer.add(fileListAreaAfter)

typeContainer.add(newLabel("from: "))
typeContainer.add(fromCombobox)
typeContainer.add(newLabel("to: "))
typeContainer.add(toCombobox)

renameContainer.add(renameCheckbox)
renameContainer.add(renameField)

mainContainer.add(topContainer)
mainContainer.add(listContainer)
mainContainer.add(typeContainer)
mainContainer.add(renameContainer)
mainContainer.add(renameButton)

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

proc replaceNames(textures_old: seq[string], fromType: string, toType: string, newNameBody: string): seq[string] =

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

    if toType == "Mari":
      newBody = newNameBody & "." & newType & ext
    else:
      newBody = newNameBody & newType & ext

    newPath = joinPath(dir, newBody)

    textures_new.add(newPath)
  return textures_new

proc getNewNames(nameBody = none(string)) =
  
  let fromType = fromCombobox.value
  let toType = toCombobox.value
  if fromType == toType:
    fileListAreaAfter.text=""
    return

  let textAreaStr = fileListAreaBefore.text
  if textAreaStr == "":
    return

  let textures_old = splitLines(textAreaStr)

  var textures_new: seq[string]

  try:
    if nameBody.isSome:
      textures_new = replaceNames(textures_old, fromType, toType, nameBody.get)
    else:
      textures_new = convertNames(textures_old, fromType, toType)
  except Exception:
    window.alert("Failed to convert names. Change the from/to setting.")
    return

  fileListAreaAfter.text=""
  if textures_new.len > 0:
    for newName in textures_new:
      fileListAreaAfter.addLine(newName)


openButton.onClick = proc(event: ClickEvent) =
  var dialog = newOpenFileDialog()
  dialog.title = "Select textures"
  dialog.multiple = true
  dialog.run()
  if dialog.files.len > 0:
    for file in dialog.files:
      fileListAreaBefore.addLine(file)

  getNewNames()

fromCombobox.onChange=proc(event: ComboBoxChangeEvent) =
  getNewNames()

toCombobox.onChange=proc(event: ComboBoxChangeEvent) =
  getNewNames()

renameField.onTextChange=proc(event: TextChangeEvent) =
  
  if renameCheckbox.checked():
    let name = renameField.text
    getNewNames(some(name))
  else:
    discard

renameButton.onClick=proc(event: ClickEvent) =


  let textAreaStr = fileListAreaBefore.text
  if textAreaStr == "":
    window.alert("No textures are loaded")
    return

  let textures_old = splitLines(textAreaStr)

  let textAreaStrAfter = fileListAreaAfter.text
  if textAreaStrAfter == "":
    window.alert("No outputs defined")
    return

  let textures_new = splitLines(textAreaStrAfter)

  let res = window.msgBox("Rename Textures? ____ ", "Rename", "Ok", "Cancel")

  if res == 1:
    for pair in zip(textures_old, textures_new):
        let (o, n) = pair
        if fileExists(o):
          moveFile(o, n)
        else:
          echo fmt("{o} doesn't exist. Skipped")

    window.msgBox("Done")

window.show()
app.run()
