/**
* Name: mstp3PAZIMNASolibia
* Author: basile
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model mstp3PAZIMNASolibia

global {
	/** Insert the global definitions, variables and actions here */
	int nbre_points_dangers <- 10 parameter: "Nbre de points dangers";
	int nbre_robots <- 5 parameter: "Nbre de points dangers";
	geometry zoneIncident <- circle(700);

	init {
		create Centre number: 1{}
		create PointDanger number: nbre_points_dangers{}
		create Robbot number: nbre_robots{}
	}		
}


species Centre{
	point location init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #green;
	float size <- 10.0;
	
	aspect basic {
		draw square(size) color:couleur;
	}
}

species PointDanger{
	point location init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #red;
	float size <- 2.0;
	int dangerLevel;
	Panneau panneau;
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}

species Panneau{
	point location init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #red;
	float size <- 2.0;
	int dangerLevel;
	
	aspect basic {
		draw circle(size) color:couleur;
	}
}

species Robbot skills:[moving]{
	point location init:[rnd(100-4*size)+size,rnd(100-4*size)+size];
	rgb couleur <-  #yellow;
	float size <- 2.5;
	float speed <- rnd(20)+1.0;
	float rayon_observation;
	float rayon_communication;
	Centre centre;
	list pointsDanger;
	geometry zoneVisited;

	reflex deplacement_hazard when: length(pointsDanger)=0 {
		//write "En deplacement";
		do action: wander amplitude: 180;
	}
		
	reflex visiter when:(zoneIncident.area != zoneVisited.area){
		//let x <- le point le plus proche qui n'est pas encore visité
		let x value: location closest_points_with(zoneVisited);
		//let x value: first (list(Centre)sort_by(self distance_to each));	
		do goto target: x[0];	
		//Mettre a jour zone visité
	}
	
	reflex detect_dange{
		//list listpoint <- les points dangers dans rayon_observation
		let listDespointDangers  value:  agents_at_distance(rayon_observation);
		//creer un panneau pour chaque point
		if(length(listDespointDangers)>0){
			loop i from: 0 to: length(listDespointDangers)-1  {
				create Panneau number: 1{
					location  <- listDespointDangers[i].location;
				}
				//mettre a jour listpoints danger				
				add listDespointDangers[i] to: pointsDanger;																												
			}
		}
	}
	
	reflex return_centre when:zoneVisited=zoneIncident{
		do goto target: centre;
	}
	
	reflex rencontre_robot{
		//list listRobot <- list les robots dans rayon_observation
		list listRobot <- agents_at_distance(rayon_observation);
		ask listRobot {
			//Metre à jour listPointsDanger et zonevisited
			myself.pointsDanger <- pointsDanger + myself.pointsDanger;
			
			//do mettre_a_jour_pointDangers_zoneVisited;
		}
		//mettre a jour listPointsDanger et zoneVisited
	}
		
	reflex communication_centre when: self distance_to centre < rayon_communication {
		ask centre {
			//mettre a jour listpointsdanger
		}
	}

	action mettre_a_jour_pointDangers_zoneVisited{
		//Metre à jour listPointsDanger et zonevisited
		self.pointsDanger <- pointsDanger + self.pointsDanger;
		//myself.pointsDanger <- add_geometry (zoneVisited,zoneVisited); 
		//self.zoneVisited <- add_point (self.zoneVisited,zoneVisited);			
		//myself.zoneVisited add_geometry (zoneVisited); 
	}
	
	aspect basic {
		draw square(size) color:couleur;
	}
	
}

	
experiment mstp3PAZIMNASolibia type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display mstp3PAZIMNASolibia {
			species Centre aspect: basic;
			species PointDanger aspect: basic;
			species Panneau aspect: basic;
			species Robbot aspect: basic;			
		}		
	}
}
