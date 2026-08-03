#!/bin/bash
# deploy.sh - pull latest from git, compile, and deploy into Tomcat
# Usage: run from your project root, e.g.:
#   cd "/Users/anthonymoll/Documents/sum26 cs157a/worldcup2026"
#   ./deploy.sh

set -e  # stop immediately if any step fails, instead of continuing on errors

TOMCAT="/Library/Tomcat"

echo "== 1. Pulling latest from git =="
git pull

echo "== 2. Compiling Java sources into Tomcat =="
javac -cp "$TOMCAT/lib/*" \
  -d "$TOMCAT/webapps/ROOT/WEB-INF/classes" \
  src/main/java/*.java \
  src/main/java/dao/*.java \
  src/main/java/model/*.java \
  src/main/java/util/*.java

echo "== 3. Copying JSPs/CSS/static files into Tomcat =="
cp -r src/main/webapp/* "$TOMCAT/webapps/ROOT/"

echo "== 4. Restarting Tomcat =="
"$TOMCAT/bin/shutdown.sh"
sleep 2
rm -rf "$TOMCAT/work/Catalina/localhost/ROOT"
"$TOMCAT/bin/startup.sh"

echo ""
echo "== Done. Waiting a few seconds, then checking the log... =="
sleep 5
tail -15 "$TOMCAT/logs/catalina.out"
echo ""
echo "If the last line above says 'Server startup in [XXX] milliseconds' with no SEVERE errors, you're good."
echo "Reload http://localhost:8080/ to check."
