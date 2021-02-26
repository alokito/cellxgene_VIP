#!/usr/bin/env bash
## obtain original index_template.html etc.
cd cellxgene
git checkout d99aac49564b98a51ebfab114fd59846c693fd62 client/index_template.html client/src/components/leftSidebar/topLeftLogoAndTitle.js client/src/components/leftSidebar/index.js
cd ..

read -d '' insertL << EOF
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jquery.min.js"></script>
<script src="https://d3js.org/d3.v4.min.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/stackedbar/d3.v3.min.js"></script>
<link href="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/jspanel.css" rel="stylesheet">
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/jspanel.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/modal/jspanel.modal.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/tooltip/jspanel.tooltip.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/hint/jspanel.hint.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/layout/jspanel.layout.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/contextmenu/jspanel.contextmenu.js"></script>
<script src="https://interactivereport.github.io/cellxgene_VIP/static/jspanel/dist/extensions/dock/jspanel.dock.js"></script>
<script>
    // execute JavaScript code in panel content
    var setInnerHTML = function(elm, html) {
        elm.innerHTML = html;
        Array.from(elm.querySelectorAll('script')).forEach( oldScript => {
            const newScript = document.createElement('script');
            Array.from(oldScript.attributes)
            .forEach( attr => newScript.setAttribute(attr.name, attr.value) );
            newScript.appendChild(document.createTextNode(oldScript.innerHTML));
            oldScript.parentNode.replaceChild(newScript, oldScript);
        });
    }
    var plotPanel = jsPanel.create({
        panelSize: '190 0',
        position: 'left-top 160 6',
        dragit: { containment: [-10, -2000, -4000, -2000] }, // set dragging range of VIP window
        boxShadow: 1,
        border: "solid #D4DBDE thin",
        contentOverflow: 'scroll scroll', // adding scrolling bars
        headerControls:{
          close: 'remove',
          minimize: 'remove',
          maximize: 'remove'
        },
        headerTitle: function () {return '<strong>Visualization in Plugin</strong>'},
        contentAjax: {
            url: 'static/interface.html',
            done: function (panel) {
                   setInnerHTML(panel.content, this.responseText);
            }
        },
        onwindowresize: function(event, panel) {
            var jptop = parseInt(this.currentData.top);
            var jpleft = parseInt(this.currentData.left);
            if (jptop<-10 || window.innerHeight-jptop<10 || window.innerWidth-jpleft<10 || jpleft+parseInt(this.currentData.width)<10) {
                this.reposition("left-top 160 6");
            }
        },
        onunsmallified: function (panel, status) {
            this.reposition('center-top -370 180');
            this.resize({ width: 740, height: function() { return Math.min(480, window.innerHeight*0.6);} });
        },
        onsmallified: function (panel, status) {
            this.reposition('left-top 160 6');
            this.style.width = '190px';
        }
    }).smallify();
    plotPanel.headerbar.style.background = "#D4DBDE";
</script>
EOF
insertL=$(sed -e 's/[&\\/]/\\&/g; s/|/\\|/g; s/$/\\/;' -e '$s/\\$//' <<<"$insertL")
sed -i "s|<div id=\"root\"></div>|$insertL\n&|" "cellxgene/client/index_template.html"

# sed -i "s|globals.datasetTitleMaxCharacterCount|50|; s|width: \"190px\"|width: \"300px\"|; s|{aboutURL ? <a href={aboutURL}|{myURL ? <a href={myURL}|; s|return|var myURL=displayTitle.split('_')[0].startsWith('GSE') \? 'https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc='\+displayTitle.split('_')[0]:aboutURL;\n    \n    return|" "cellxgene/client/src/components/leftSidebar/topLeftLogoAndTitle.js"

sed -i "s|logoRelatedPadding = 50|logoRelatedPadding = 60|" "cellxgene/client/src/components/leftSidebar/index.js"

strPath=$(python -c "import server as _; print(_.__file__.replace('/server/__init__.py',''))")
cd cellxgene/client; make build
cp build/index.html $strPath/server/common/web/templates/
rm $strPath/server/common/web/static/main-*.*
rm $strPath/server/common/web/static/obsolete-*.*
cp build/static/*   $strPath/server/common/web/static/
cd ../..
