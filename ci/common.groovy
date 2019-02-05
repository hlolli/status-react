import groovy.json.JsonBuilder

gh = load 'ci/github.groovy'
ci = load 'ci/jenkins.groovy'
gh = load 'ci/github.groovy'
utils = load 'ci/utils.groovy'
ghcmgr = load 'ci/ghcmgr.groovy'

/* Small Helpers -------------------------------------------------------------*/

def pkgUrl(build) {
  return utils.getEnv(build, 'PKG_URL')
}

def updateLatestNightlies(urls) {
  /* latest.json has slightly different key names */
  def latest = [
    APK: urls.Apk, IOS: urls.iOS,
    APP: urls.App, MAC: urls.Mac,
    WIN: urls.Win, SHA: urls.SHA
  ]
  def latestFile = pwd() + '/' + 'pkg/latest.json'
  /* it might not exist */
  sh 'mkdir -p pkg'
  def latestJson = new JsonBuilder(latest).toPrettyString()
  println "latest.json:\n${latestJson}"
  new File(latestFile).write(latestJson)
  return utils.uploadArtifact(latestFile)
}

def notifyPR(success) {
  if (utils.changeId() == null) { return }
  try {
    ghcmgr.postBuild(success)
  } catch (ex) { /* fallback to posting directly to GitHub */
    println "Failed to use GHCMGR: ${ex}"
    switch (success) {
      case true:  gh.NotifyPRSuccess(); break
      case false: gh.NotifyPRFailure(); break
    }
  }
}

return this
