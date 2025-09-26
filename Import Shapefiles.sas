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

/* This code creates a new table with a NUMERIC district ID and the sequence column */
data Public.DISTRICTS_FOR_PROVIDER (promote=yes drop=DISTRICT rename=(DISTRICT_NUM=DISTRICT));
    set Public.CONGRESS_DISTRICTS;
    by DISTRICT SEGMENT;

    /* Convert the original text DISTRICT to a number */
    DISTRICT_NUM = input(DISTRICT, 8.); 
    
    /* Create the vertex order sequence */
    if first.SEGMENT then VERTEX_ORDER = 1;
    else VERTEX_ORDER + 1;
run;
proc casutil;
    save casdata="DISTRICTS_FOR_PROVIDER" /* The in-memory table to save */
    incaslib="Public"                   /* Where to find the in-memory table */
    outcaslib="Public"                  /* Where to save the physical file */
    replace;                            /* Overwrite if it already exists */
run;


