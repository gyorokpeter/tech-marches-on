if[()~key `.tmo.dataDir;
    .tmo.dataDir:`$":",.finos.dep.resolvePath["../data"];
    .tmo.metaPath:`$":",.finos.dep.joinPath(1_string .tmo.dataDir;"meta.txt");
    .tmo.outPath:`$":",.finos.dep.resolvePath["../tmo.svg"];
    ];

.tmo.logistic:{[height;rate;xoff;yoff;x]yoff+height%1+exp neg[rate]*x-xoff};
.tmo.derlogistic:{[height;rate;xoff;yoff;x]yoff+height*exp[x1]%s*s:1+exp x1:(rate*x)-xoff};

.tmo.a1:5;
.tmo.b1:0.06;
.tmo.x1:40;
.tmo.y1:0;
.tmo.a2:30;
.tmo.b2:0.24;
.tmo.x2:5;
.tmo.y2:0;

.tmo.pts:800;

.tmo.curveXs:{til[1+.tmo.pts]%.tmo.pts%100};

.tmo.tmoCurve:{
    xs:.tmo.curveXs[];
    ca:.tmo.logistic[.tmo.a1;.tmo.b1;.tmo.x1;.tmo.y1] xs;
    cb:.tmo.derlogistic[.tmo.a2;.tmo.b2;.tmo.x2;.tmo.y2] xs;
    ca+cb};

//last year done: 2006 going down
.tmo.showYear:2005;
//.tmo.showYear:0Ni;

.tmo.aggregate:{
    .tmo.ref:1!("S**";enlist",")0:.tmo.metaPath;
    exec `s#lower sym from .tmo.ref;
    //select from ([]a:exec lower sym from .tmo.ref;b:exec asc lower sym from .tmo.ref)where a<>b

    files:key .tmo.dataDir;
    years:"J"$first each "."vs/:string files;
    good:where not null years;
    files2:files good;
    years2:years good;
    allData:raze{[dataDir;f;y]update year:y from ("SFF";enlist",")0:read0 .Q.dd[dataDir;f]}[.tmo.dataDir]'[files2;years2];
    if[not null .tmo.showYear;
        allData:select from allData where year=.tmo.showYear;
    ];
    grpData:select year,prg,ytm by sym from allData;
    progress:grpData;
    if[null .tmo.showYear;
        progress:select from grpData where 2<=count each year;
    ];
    progress};

.tmo.point:{
    (.h.htac[`use;`href`transform!("#",(`s#0 2 5 10f!("2y-";"2y5y";"5y10y";"10y+"))x[`ytm];"translate(",string[x`x],",",string[x`y],")");""];
    .h.htac[`text;`x`y!string(6+x`x;5+x`y);.tmo.ref[x`sym;`label]])};
.tmo.animPoint:{[minYear;maxYear;dur;x]
    if[first[x`year]>minYear;
        ly:2#x`year;
        lprg:2#x`animprg;
        rate:(lprg[1]-lprg[0])%ly[1]-ly[0];
        x[`year]:minYear,x`year;
        x[`animprg]:(first[lprg]-(first[ly]-minYear)*rate),x`animprg;
    ];
    if[last[x`year]<maxYear;
        ly:-2#x`year;
        lprg:-2#x`animprg;
        rate:(lprg[1]-lprg[0])%ly[1]-ly[0];
        x[`year],:maxYear;
        x[`animprg],:last[lprg]+(maxYear-last ly)*rate;
    ];
    times:";"sv string (x[`year]-first[x`year])%last[x`year]-first[x`year];
    .h.htc[`g][
        .h.htac[`use;enlist[`href]!enlist"#",(`s#0 2 5 10f!("2y-";"2y5y";"5y10y";"10y+"))first x[`ytm];""]
        ,.h.htac[`text;`x`y!string 6 5;.tmo.ref[x`sym;`label]]
        ,.h.htac[`animateMotion;`fill`dur`calcMode`keyTimes`keyPoints`repeatCount!("freeze";dur;"linear";times;";"sv string x[`animprg];"indefinite");
            .h.htac[`mpath;enlist[`href]!enlist"#curve";""]
        ]
    ]};

.tmo.svg:{
    .tmo.ref:1!("S**";enlist",")0:read0 .tmo.metaPath;
    data:.tmo.aggregate[];
    data:0!update ind:`int$prg*.tmo.pts%100 from data;
    minYear:exec min min each year from data;
    maxYear:exec max max each year from data;
    curve:.tmo.tmoCurve[];
    curveLeft:10;
    curveTop:40;
    curveWidth:840;
    curveHeight:460;
    curveX:curveLeft+curveWidth*til[1+.tmo.pts]%.tmo.pts;
    curve-:min curve;
    curveY:curveTop+curveHeight-curveHeight*curve%max[curve];

    step:(last[curveX]-first[curveX])%.tmo.pts;
    dists:{x%last x}sums 0,sqrt(step*step)+{x*x}1_deltas curveY;
    data:update animprg:dists(`long$data[`prg]*.tmo.pts%100) from data;

    yearsLeft:curveLeft+30;
    yearsTop:curveTop+curveHeight+40;
    yearsRight:(2*curveLeft)+curveWidth-30;
    yearsLineTop:yearsTop-25;
    yearsMarkerTop:yearsLineTop-5;
    years:exec asc distinct raze year from data;
    yearsPos:yearsLeft+til[count years]*(yearsRight-yearsLeft)%count[years]-1;
    dur:"5s";
    pts:.tmo.point each select sym,x:curveX ind, y:curveY ind, ytm from ungroup select sym,ind,ytm from data;
    .h.htac[`svg;`xmlns`xmlns:xlink`width`height!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";string[curveWidth+curveLeft];string[curveHeight+curveTop+40]);
        .h.htc[`defs;
            .h.htac[`g;enlist[`id]!enlist"2y-";.h.htac[`circle;`cx`cy`r`stroke`fill!string(0;0;5;`black;`white);""]]
            ,.h.htac[`g;enlist[`id]!enlist"2y5y";.h.htac[`circle;`cx`cy`r`stroke`fill!string(0;0;5;`black;`LightSkyBlue);""]]
            ,.h.htac[`g;enlist[`id]!enlist"5y10y";.h.htac[`circle;`cx`cy`r`stroke`fill!string[(0;0;5;`black)],enlist["#003399"];""]]
            ,.h.htac[`g;enlist[`id]!enlist"10y+";.h.htac[`circle;`cx`cy`r`fill`stroke!string(0;0;5;`black;`black);""]]
        ]
        ,.h.htac[`text;(`x`y,`$("font-size";"text-anchor"))!string[(curveLeft+curveWidth div 2;24;22)],enlist"middle";"Technology marches on"]
        ,.h.htac[`path;(`id`stroke`d,(`$("stroke-width")),`fill)!("curve";"black";"M",1_raze"L ",/:" "sv/:string curveX,'curveY;string 1;"none");""]
        ,$[null .tmo.showYear;""
            ,raze[.tmo.animPoint[minYear;maxYear;dur] each data]
            ,raze[{[top;x;y].h.htac[`text;(`x`y,`$"text-anchor")!string[(x;top)],enlist"middle";string y]}[yearsTop]'[yearsPos;years]]
            ,.h.htac[`line;(`x1`y1`x2`y2`stroke,`$"stroke-width")!string[(yearsLeft-10;yearsLineTop;yearsRight+10;yearsLineTop)],enlist["black"],enlist string 2;""]
            ,raze[{[top;x].h.htac[`line;(`x1`y1`x2`y2`stroke,`$"stroke-width")!string[(x;top;x;top+10)],enlist["black"],enlist string 2;""]}[yearsLineTop]'
                [yearsPos]]
            ,.h.htac[`g;()!();""
                ,.h.htac[`polygon;enlist[`points]!enlist"-5,-5 5 -5 0 5";""]
                ,.h.htac[`animateTransform;`attributeName`attributeType`fill`dur`type`from`to`repeatCount!("transform";"XML";
                    "freeze";dur;"translate";" "sv string(yearsLeft;yearsMarkerTop);" "sv string(yearsRight;yearsMarkerTop);"indefinite");""]
            ];
            raze[pts[;1]],raze[pts[;0]]
        ]
    ]};

tmoGen:{[fn]fn 0:enlist .tmo.svg[]};

.tmo.getPage:{
    needRefresh:not null .tmo.showYear;
    .h.hy[`htm].h.htc[`html]$[needRefresh;.h.htc[`head;.h.htac[`meta;(`$("http-equiv";"content"))!("refresh";"1");""]];""]
        ,.h.htc[`body].h.htac[`object;`data`type`id!("tmo.svg";"image/svg+xml";"tmo");""]};

.html.commandHandlers[`tmo.svg]:`.tmo.getSvg;
.html.commandHandlers[`tmo]:`.tmo.getPage;

.tmo.getSvg:{.h.hy[`svg;.tmo.svg[]]};
