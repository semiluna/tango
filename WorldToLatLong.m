function longLat = WorldToLatLong(world)

x = world(1);
y = world(2);

lat = ((y + 44.9522 - -304.7138977050781) / (306.7823181152344 - -304.7138977050781)) * (52.21181068833085 - 52.20845925039107) + 52.20845925039107;
long = ((x - -554.8467407226562) / (515.2716064453125 - -554.8467407226562)) * (0.09611646188477406 - 0.08651724966864788) + 0.08651724966864788;

longLat = [lat, long];