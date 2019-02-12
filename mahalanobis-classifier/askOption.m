function option = askOption()
    % Print the menu for the console app.
    disp('Selecciona el algoritmo de clasificación:');
    disp('1. Distancia Euclideana Mínima.');
    disp('2. Distancia de Mahalanobis.');
    disp('3. Salir.');
    option = input('Ingresa una opción : ');
end

