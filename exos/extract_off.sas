proc sql;
	create table offres_stmt19 as
		select dpteta,
				sum(nbroff) as nb_off
		from off_rest.offre_stmt
		where natregoff = "ENREG" and moista between "201901" and "201912"
		group by dpteta;
quit;