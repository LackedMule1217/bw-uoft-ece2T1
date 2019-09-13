/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   TreeNode.cpp
 * Author: weishij2
 * 
 * Created on November 24, 2018, 12:23 PM
 */

#include "TreeNode.h"



// A) Constructors
TreeNode::TreeNode(DBentry* _entryPtr) {
    entryPtr = _entryPtr;
    left = nullptr;
    right = nullptr;
}

// B) Destructor
TreeNode::~TreeNode() {
    delete entryPtr;
}

// C) Mutators
//     C.1) Sets the left child of the TreeNode
void TreeNode::setLeft(TreeNode* newLeft) {
    left = newLeft;
}
//     C.2) Sets the right child of the TreeNode
void TreeNode::setRight(TreeNode* newRight) {
    right = newRight;
}

// D) Accessors
//     D.1) Gets the left child of the TreeNode
TreeNode* TreeNode::getLeft() const {
    return left;
}
//     D.2) Gets the right child of the TreeNode
TreeNode* TreeNode::getRight() const {
    return right;
}
//     D.3) Returns a pointer to the DBentry of TreeNode contains
DBentry* TreeNode::getEntry() const {
    return entryPtr;
}
