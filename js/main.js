import AVLTree from "./tree.js";

const tree = new AVLTree();

// Insertar datos de prueba
tree.insert({
  id: 1,
  gravedad: 50,
  tipoDelito: "Injuria"
});

tree.insert({
  id: 2,
  gravedad: 30,
  tipoDelito: "Calumnia"
});

tree.insert({
  id: 3,
  gravedad: 70,
  tipoDelito: "Suplantación"
});

tree.insert({
  id: 4,
  gravedad: 80,
  tipoDelito: "Hostigamiento"
});

tree.insert({
  id: 5,
  gravedad: 20,
  tipoDelito: "Amenaza"
});

// Mostrar resultados
console.log("Inorden:", tree.inOrder());
console.log("Preorden:", tree.preOrder());
console.log("Árbol completo:", tree.getTreeData());
