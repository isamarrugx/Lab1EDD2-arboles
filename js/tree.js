class CaseNode {
  constructor(caseData) {
    this.id = caseData.id;
    this.gravedad = caseData.gravedad;
    this.tipoDelito = caseData.tipoDelito;
    this.evidencias = caseData.evidencias || [];
    this.ley = caseData.ley || "";
    this.sancion = caseData.sancion || "";

    this.left = null;
    this.right = null;
    this.height = 1;
  }
}

class AVLTree {
  constructor() {
    this.root = null;
  }

  getHeight(node) {
    return node ? node.height : 0;
  }

  getBalance(node) {
    return node ? this.getHeight(node.left) - this.getHeight(node.right) : 0;
  }

  updateHeight(node) {
    node.height = 1 + Math.max(this.getHeight(node.left), this.getHeight(node.right));
  }

  rotateRight(y) {
    const x = y.left;
    const T2 = x.right;

    x.right = y;
    y.left = T2;

    this.updateHeight(y);
    this.updateHeight(x);

    return x;
  }

  rotateLeft(x) {
    const y = x.right;
    const T2 = y.left;

    y.left = x;
    x.right = T2;

    this.updateHeight(x);
    this.updateHeight(y);

    return y;
  }

  insert(caseData) {
    this.root = this._insert(this.root, caseData);
  }

  _insert(node, caseData) {
    if (!node) {
      return new CaseNode(caseData);
    }

    if (caseData.gravedad < node.gravedad) {
      node.left = this._insert(node.left, caseData);
    } else if (caseData.gravedad > node.gravedad) {
      node.right = this._insert(node.right, caseData);
    } else {
      // Si la gravedad se repite, desempata por id
      if (caseData.id < node.id) {
        node.left = this._insert(node.left, caseData);
      } else {
        node.right = this._insert(node.right, caseData);
      }
    }

    this.updateHeight(node);

    const balance = this.getBalance(node);

    // Caso Izquierda-Izquierda
    if (balance > 1 && caseData.gravedad < node.left.gravedad) {
      return this.rotateRight(node);
    }

    // Caso Derecha-Derecha
    if (balance < -1 && caseData.gravedad > node.right.gravedad) {
      return this.rotateLeft(node);
    }

    // Caso Izquierda-Derecha
    if (balance > 1 && caseData.gravedad > node.left.gravedad) {
      node.left = this.rotateLeft(node.left);
      return this.rotateRight(node);
    }

    // Caso Derecha-Izquierda
    if (balance < -1 && caseData.gravedad < node.right.gravedad) {
      node.right = this.rotateRight(node.right);
      return this.rotateLeft(node);
    }

    return node;
  }

  searchByGravedad(gravedad) {
    return this._searchByGravedad(this.root, gravedad);
  }

  _searchByGravedad(node, gravedad) {
    if (!node) return null;

    if (gravedad === node.gravedad) return node;

    if (gravedad < node.gravedad) {
      return this._searchByGravedad(node.left, gravedad);
    }

    return this._searchByGravedad(node.right, gravedad);
  }

  inOrder() {
    const result = [];
    this._inOrder(this.root, result);
    return result;
  }

  _inOrder(node, result) {
    if (!node) return;

    this._inOrder(node.left, result);
    result.push(this.nodeToObject(node));
    this._inOrder(node.right, result);
  }

  preOrder() {
    const result = [];
    this._preOrder(this.root, result);
    return result;
  }

  _preOrder(node, result) {
    if (!node) return;

    result.push(this.nodeToObject(node));
    this._preOrder(node.left, result);
    this._preOrder(node.right, result);
  }

  postOrder() {
    const result = [];
    this._postOrder(this.root, result);
    return result;
  }

  _postOrder(node, result) {
    if (!node) return;

    this._postOrder(node.left, result);
    this._postOrder(node.right, result);
    result.push(this.nodeToObject(node));
  }

  levelOrder() {
    const result = [];
    if (!this.root) return result;

    const queue = [this.root];

    while (queue.length > 0) {
      const current = queue.shift();
      result.push(this.nodeToObject(current));

      if (current.left) queue.push(current.left);
      if (current.right) queue.push(current.right);
    }

    return result;
  }

  getMinNode(node = this.root) {
    if (!node) return null;

    let current = node;
    while (current.left) {
      current = current.left;
    }
    return current;
  }

  getMaxNode(node = this.root) {
    if (!node) return null;

    let current = node;
    while (current.right) {
      current = current.right;
    }
    return current;
  }

  getTreeData() {
    return this._buildTreeData(this.root);
  }

  _buildTreeData(node) {
    if (!node) return null;

    return {
      id: node.id,
      gravedad: node.gravedad,
      tipoDelito: node.tipoDelito,
      evidencias: node.evidencias,
      ley: node.ley,
      sancion: node.sancion,
      height: node.height,
      balance: this.getBalance(node),
      left: this._buildTreeData(node.left),
      right: this._buildTreeData(node.right),
    };
  }

  nodeToObject(node) {
    return {
      id: node.id,
      gravedad: node.gravedad,
      tipoDelito: node.tipoDelito,
      evidencias: node.evidencias,
      ley: node.ley,
      sancion: node.sancion,
      height: node.height,
      balance: this.getBalance(node),
    };
  }
}

export default AVLTree;
