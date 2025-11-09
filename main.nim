import dom

var urls: seq[string] = @[]

proc loadSavedUrls() =
  {.emit: """
    browser.storage.local.get('savedUrls').then(result => {
      if (result.savedUrls) {
        window.urls = result.savedUrls;
        document.getElementById("urls").innerHTML = 
          window.urls.map(url => '<li>' + url + '</li>').join('');
      }
    });
  """.}

proc getAllTabs() =
  {.emit: """
    browser.tabs.query({}).then(tabs => {
      window.urls = tabs.map(tab => tab.url);
      document.getElementById("urls").innerHTML = 
        window.urls.map(url => '<li>' + url + '</li>').join('');
    });
  """.}

proc saveSessionData(): string =
  if urls.len == 0: 
    return "No tabs to save."
  {.emit: """
    browser.storage.local.set({
      savedUrls: window.urls,
      savedDate: new Date().toISOString()
    }).then(() => {
      window.alert('Session saved successfully!');
    }).catch(err => {
      window.alert('Error saving session: ' + err);
    });
  """.}
  return ""

proc main() =
  let content = document.getElementById("content")
  content.innerHTML = """
    <p>Your Firefox Tabs:</p>
    <p>------------------</p>
    <ul id="urls"></ul>
  """ 
  getAllTabs()

  let button = document.createElement("button")
  button.innerHTML = "Save Session"
  button.onclick = proc(e: Event) =
    var saveResponse = saveSessionData()
    if saveResponse.len == 0: 
      window.alert(saveResponse)

  content.appendChild(button)

when isMainModule:
  main()