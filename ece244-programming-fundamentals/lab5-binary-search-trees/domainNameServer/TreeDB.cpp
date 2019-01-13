/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   TreeDB.cpp
 * Author: weishij2
 * 
 * Created on November 24, 2018, 12:24 PM
 */

#include "TreeDB.h"



// A) Constructors
TreeDB::TreeDB() {
    root = nullptr;
    probesCount = 0;
}

// B) Destructor
TreeDB::~TreeDB() {
    deleteTreeRecur(root);
}
//    B.1) Destructor helper function
void TreeDB::deleteTreeRecur(TreeNode* root) {
    if (root == nullptr) return;
    deleteTreeRecur(root->getLeft());
    deleteTreeRecur(root->getRight());
    delete root;
}

// C) Mutators
//    C.1) Inserts inserts the entry pointed to by newEntry into the database.
//         If an entry with the same key as newEntry's exists in the database, it returns false.
//         Otherwise, it returns true.
bool TreeDB::insert(DBentry* newEntry) {
    // 1) Check if 'newEntry' is nullptr
    if (newEntry == nullptr) return false;
    // 2) Check if 'root' is nullptr and if true, insert the node
    if (root == nullptr) {
        root = new TreeNode(newEntry);
        return true;
    }
    // 3) Use recursion to try and locate node and insert payload
    else {
        // 3.1) Locate the node in the tree to insert by calling 'insertNodeRecur' method
        TreeNode* insertLoc = insertNodeRecur(root, newEntry->getName());
        // 3.2) Return false if node with same key already exists
        if (insertLoc == nullptr) return false;
        // 3.3) Insert payload
        TreeNode* newNode = new TreeNode(newEntry);
        if ((newEntry->getName()) < (insertLoc->getEntry()->getName()))         insertLoc->setLeft(newNode);
        else if ((newEntry->getName()) > (insertLoc->getEntry()->getName()))    insertLoc->setRight(newNode);
    }
    // 4) Return true for insertion success
    return true;
}
//           C.1.1) Insert helper function
TreeNode* TreeDB::insertNodeRecur (TreeNode* root, string key) const {
    // 1) Base case: returns insertion node
    //     Returns nullptr if node with same key as 'key' is encountered during tree traversal
    if (key == root->getEntry()->getName()) return nullptr;
    else if ((key < root->getEntry()->getName()) && (root->getLeft() == nullptr)) return root;
    else if ((key > root->getEntry()->getName()) && (root->getRight() == nullptr)) return root;
    // 2) Use recursion to traverse through tree
    if (key < (root->getEntry()->getName())) return insertNodeRecur(root->getLeft(), key);
    else if (key > (root->getEntry()->getName())) return insertNodeRecur(root->getRight(), key);
}
//     C.2) Searches the database for an entry with a key equal to name.
//            If the entry is found, a pointer to it is returned.
//            If the entry is not found, the nullptr pointer is returned.
//            Also sets probesCount
DBentry* TreeDB::find(string name) {
    // 1) Reset 'probesCount'
    probesCount = 0;
    // 2) Call 'findNodeRecur' method
    return findNodeRecur(root, name);
}
//          C.2.1) Search helper function
DBentry* TreeDB::findNodeRecur(TreeNode* root, string key) {
    // 1) Increment probesCount
    probesCount++;
    // 2) Base case: returns nullptr if node not found
    if (root == nullptr) return nullptr;
    // 3) Use recursion to traverse through tree
    if (key < root->getEntry()->getName()) return findNodeRecur(root->getLeft(), key);
    else if (key > root->getEntry()->getName()) return findNodeRecur(root->getRight(), key);
    //    3.1) Returns 'root->getEntry()' if node with same key as 'key' is encountered during tree traversal
    else return root->getEntry();
}
//     C.3) Deletes the entry with the specified name (key) from the database.
//          If the entry was indeed in the database, it returns true. Returns false otherwise.
bool TreeDB::remove(string name) {
    TreeNode* prevNode;
    TreeNode* deletedNode;
    // 0) Check if tree is empty
    if (root == nullptr) return false;
    // 1) If 'name' is the key of 'root'
    if (root->getEntry()->getName() == name) {
        // 1.1) Check for which one of the three deletion methods to employ
        //        1.1.1) Method 1: Removes leaf node
        if ((root->getLeft() == nullptr) && (root->getRight() == nullptr)) {
            delete root;
            root = nullptr;
        }
        //        1.1.2) Method 2: Removes node with two subtrees
        else if ((root->getLeft() != nullptr) && (root->getRight() != nullptr)) {
            //              1.1.2.0) Instantiate variables
            TreeNode* mostRightPrevSubNode;
            TreeNode* mostRightSubNode;
            //              1.1.2.1) Get most right subnode on the left sub-node of the root
            if (getMostRightPrevSubNodeRecur(root->getLeft()) == nullptr) {
                mostRightSubNode = root->getLeft();
                mostRightSubNode->setRight(root->getRight());
                delete root;
                root = mostRightSubNode;
            }
            else {
                mostRightSubNode = getMostRightPrevSubNodeRecur(root->getLeft());
                mostRightPrevSubNode = removeFindPrevNodeRecur(root, mostRightSubNode->getEntry()->getName());
                //              1.1.2.1) Set left and right sub-nodes
                mostRightSubNode->setLeft(root->getLeft());
                mostRightSubNode->setRight(root->getRight());
                mostRightPrevSubNode->setRight(nullptr);
                //              1.1.2.2) Delete root
                delete root;
                root = mostRightSubNode;
            }
        }
        //        1.1.3) Method 3: Removes node with one subtree
        else {
            TreeNode* nextNode;
            if (root->getLeft() != nullptr) nextNode = root->getLeft();
            else                                    nextNode = root->getRight();
            delete root;
            root = nextNode;
        }
        return true;
    }
    // 2) Get prevNode
    //    2.1) Call 'removeFindNodeRecur' method
    prevNode = removeFindPrevNodeRecur(root, name);
    deletedNode = removeFindNodeRecur(root, name);
    //    2.2) Return false if node was not found
    if (prevNode == nullptr) return false;
    // 3) Check for which one of the three deletion methods to employ
    //    3.1) Method 1: Removes leaf node
    if ((deletedNode->getLeft() == nullptr) && (deletedNode->getRight() == nullptr)) removeLeafNode(prevNode, name);
    //    3.2) Method 2: Removes node with two subtrees
    else if ((deletedNode->getLeft() != nullptr) && (deletedNode->getRight() != nullptr)) removeNodeTwoSub(prevNode, deletedNode);
    //    3.3) Method 3: Removes node with one subtree
    else removeNodeOneSub(prevNode, deletedNode);
    // 4) Return true for successful deletion
    return true;
}
//          C.3.1.1) Remove helper function that returns the previous node matching to the node with the matching key (name)
TreeNode* TreeDB::removeFindPrevNodeRecur(TreeNode* root, string key) {
    // 1) Base case
    if (key == root->getEntry()->getName()) return nullptr;
    else if (key < root->getEntry()->getName()) {
        if (root->getLeft() == nullptr) return nullptr;
        else if (key == root->getLeft()->getEntry()->getName()) return root;
    }
    else if (key > root->getEntry()->getName()) {
        if (root->getRight() == nullptr) return nullptr;
        else if (key == root->getRight()->getEntry()->getName()) return root;
    }
    // 2) Use recursion to traverse through tree
    if (key < root->getEntry()->getName()) return removeFindPrevNodeRecur(root->getLeft(), key);
    else if (key > root->getEntry()->getName()) return removeFindPrevNodeRecur(root->getRight(), key);
}
//          C.3.1.2) Remove helper function that returns the node matching to the node with the matching key (name)
TreeNode* TreeDB::removeFindNodeRecur(TreeNode* root, string key) {
    // 1) Base case
    if (root == nullptr) return nullptr;
    else if (key == root->getEntry()->getName()) return root;
    // 2) Use recursion to traverse through tree
    if (key < root->getEntry()->getName()) return removeFindNodeRecur(root->getLeft(), key);
    else if (key > root->getEntry()->getName()) return removeFindNodeRecur(root->getRight(), key);
}
//          C.3.2) Method 1: Removes leaf node
void TreeDB::removeLeafNode(TreeNode* prevNodePtr, string key) {
    // 1) Determine which sub-node to remove and then remove it
    if ((prevNodePtr->getLeft() != nullptr) && (key == prevNodePtr->getLeft()->getEntry()->getName())) {
        delete prevNodePtr->getLeft();
        prevNodePtr->setLeft(nullptr);
    }
    else {
        delete prevNodePtr->getRight();
        prevNodePtr->setRight(nullptr);
    }
}
//          C.3.3) Method 2: Removes node with two subtrees
void TreeDB::removeNodeTwoSub(TreeNode* prevNodePtr, TreeNode* deletedNode) {
    // 0) Instantiate variables
    TreeNode* subLeftNode;
    TreeNode* subRightNode;
    TreeNode* mostRightPrevSubNode;
    TreeNode* mostRightSubNode;
    // 1) Retrieve the left and right nodes of the node to be removed
    subLeftNode = deletedNode->getLeft();
    subRightNode = deletedNode->getRight();
    // 2) Retrieve the node before the most right sub-node of 'subLeftNode' by calling 'getMostRightSubNode' method
    //    First check to see if the 'subLeftNode' do not have any right sub-child
    if (getMostRightPrevSubNodeRecur(subLeftNode) == nullptr) {
        delete deletedNode;
        if (subLeftNode->getEntry()->getName() < prevNodePtr->getEntry()->getName())
            prevNodePtr->setLeft(subLeftNode);
        else prevNodePtr->setRight(subLeftNode);
        subLeftNode->setRight(subRightNode);
        return;
    }
    mostRightPrevSubNode = getMostRightPrevSubNodeRecur(subLeftNode);
    mostRightSubNode = mostRightPrevSubNode->getRight();
    // 3) Remove 'deletedNode'
    delete deletedNode;
    // 4) Stitch back the BST by replacing the 'deletedNode' with the right node after 'mostRightPrevSubNode'
    //     4.1) If key of 'mostRightPrevSubNode->getRight()' is less than the key of 'prevNodePtr', then insert the
    //          former to latter's left or else insert to latter's right
    if (mostRightSubNode->getEntry()->getName() < prevNodePtr->getEntry()->getName())
        prevNodePtr->setLeft(mostRightSubNode);
    else prevNodePtr->setRight(mostRightSubNode);
    //     4.2) Check if 'mostRightSubNode' still have a left chain of children
    if (mostRightSubNode->getLeft() != nullptr) mostRightPrevSubNode->setRight(mostRightSubNode->getLeft());
    else mostRightPrevSubNode->setRight(nullptr);
    //     4.3) Connect the two subtrees with 'mostRightSubNode'
    mostRightSubNode->setLeft(subLeftNode);
    mostRightSubNode->setRight(subRightNode);
}
//                 C.3.3.1) Returns the most right sub-node of a BST given a starting node
TreeNode* TreeDB::getMostRightPrevSubNodeRecur(TreeNode* subLeftNode) {
    // 1) Base case
    if (subLeftNode->getRight() == nullptr) return nullptr;
    else if (subLeftNode->getRight()->getRight() == nullptr) return subLeftNode;
    // 2) Recursion
    return getMostRightPrevSubNodeRecur(subLeftNode->getRight());
}
//          C.3.4) Method 3: Removes node with one subtree
void TreeDB::removeNodeOneSub(TreeNode* prevNodePtr, TreeNode* deletedNode) {
    // 0) Instantiate variables
    TreeNode* subNode;
    // 1) Keep nodes after the node to be removed
    if (deletedNode->getLeft() != nullptr)  subNode = deletedNode->getLeft();
    else subNode = deletedNode->getRight();
    // 2) Removes 'deletedNode'
    delete deletedNode;
    // 3) Insert the nodes following the deleted nodes back into the BST to the previous node before the removed node
    //     If key of 'subNode' is less than the key of 'prevNodePtr', then insert 'subNode' to its left or else insert to its right
    if (subNode->getEntry()->getName() < prevNodePtr->getEntry()->getName())    prevNodePtr->setLeft(subNode);
    else prevNodePtr->setRight(subNode);
}
//     C.4) Deletes all the entries in the database
void TreeDB::clear() {
    // 1) Call 'deleteTreeRecur' method
    deleteTreeRecur(root);
    // 2) Set 'root' to nullptr
    root = nullptr;
}

// D) Accessors
TreeNode* TreeDB::getRoot() const {
    return root;
}

// D) Utility
//     D.1) Prints the number of probes stored in probesCount
void TreeDB::printProbes() const {
    cout << probesCount << endl;
}
//     D.2) Computes and prints out the total number of active entries in the database (i.e. entries with active==true).
void TreeDB::countActive() const {
    // 0) Instantiate variables
    int numActive;
    // 1) Check to see if current tree is empty and if not, then call 'countActiveRecur' method
    if (root != nullptr) numActive = countActiveRecur(root);
    else numActive = 0;
    // 2) Print
    cout << numActive << endl;
}
//          D.2.1) 'countActive' helper function
int TreeDB::countActiveRecur(TreeNode* root) const {
    // 1) Base condition
    if (root == nullptr) return 0;
    // 2) Recursion
    else if (root->getEntry()->getActive())  return 1 + countActiveRecur(root->getLeft()) + countActiveRecur(root->getRight());
    else if (!(root->getEntry()->getActive()))  return 0 + countActiveRecur(root->getLeft()) + countActiveRecur(root->getRight());
}

// E) Non-member functions
//     E.3) Prints the entire tree, in ascending order of key/name
ostream& operator<<(ostream& out, TreeNode* rhs) {
    if (rhs == nullptr) return out;
    operator<<(out, rhs->getLeft());
    out << *(rhs->getEntry());
    operator<<(out, rhs->getRight());
    return out;
}
