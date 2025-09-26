/* %shpimprt( */
/*   shapefilepath = "/export/viya/homes/shelly.hunt@sas.com/data/USSF/Districts/District_Shapefile.shp",  */
/*   id = DISTRICT,  */
/*   outtable = CONGRESS_DISTRICTS, */
/*   caslib = "Public", */
/*   reduce = 1 */
/* ); */


proc mapimport
    datafile="/export/viya/homes/shelly.hunt@sas.com/data/USSF/Districts/District_Shapefile.shp"
    out=WORK.DISTRICT_MAP_RAW;
    id DISTRICT;
run;

proc greduce data=WORK.DISTRICT_MAP_RAW out=WORK.DISTRICT_MAP_REDUCED;
    id DISTRICT;
run;

proc casutil;
    load data=WORK.DISTRICT_MAP_REDUCED
    outcaslib="Public"
    casout="CONGRESS_DISTRICTS"
    promote;
run;

/* This code creates a new table with the required VERTEX_ORDER column */
data Public.DISTRICTS_FOR_PROVIDER (promote=yes);
    set Public.CONGRESS_DISTRICTS;
    by DISTRICT SEGMENT; /* This groups the data by each unique polygon part */
    
    /* For the first vertex of each part, reset the counter to 1 */
    if first.SEGMENT then VERTEX_ORDER = 1;
    /* For all other vertices, increment the counter */
    else VERTEX_ORDER + 1;
run;

proc casutil;
    save casdata="DISTRICTS_FOR_PROVIDER" /* The in-memory table to save */
    incaslib="Public"                   /* Where to find the in-memory table */
    outcaslib="Public"                  /* Where to save the physical file */
    replace;                            /* Overwrite if it already exists */
run;