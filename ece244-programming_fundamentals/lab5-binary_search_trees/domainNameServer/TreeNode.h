/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   TreeNode.h
 * Author: weishij2
 *
 * Created on November 24, 2018, 12:23 PM
 */

#ifndef _TREENODE_H
#define _TREENODE_H

#include "DBentry.h"

class TreeNode {
    private:
        DBentry* entryPtr;
        TreeNode* left;
        TreeNode* right;

    public:
        // A useful constructor
        TreeNode(DBentry* _entryPtr);

        // the destructor
        ~TreeNode();

        // sets the left child of the TreeNode.
        void setLeft(TreeNode* newLeft);

        // sets the right child of the TreeNode
        void setRight(TreeNode* newRight);

        // gets the left child of the TreeNode.
        TreeNode* getLeft() const;

        // gets the right child of the TreeNode
        TreeNode* getRight() const;

        // returns a pointer to the DBentry the TreeNode contains. 
        DBentry* getEntry() const;
};

#endif /* TREENODE_H */

