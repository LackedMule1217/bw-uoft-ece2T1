/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   TreeDB.h
 * Author: weishij2
 *
 * Created on November 24, 2018, 12:24 PM
 */

#ifndef _TREEDB_H
#define _TREEDB_H

#include "TreeNode.h"
#include "DBentry.h"

#include <iostream>
#include <string>
#include <string.h>

class TreeDB {
    private:
        TreeNode* root;
        int probesCount;
        // You will need to add additional private functions
        // 1) Destructor helper function
        void deleteTreeRecur(TreeNode* root);
        // 2) Insert helper function
        TreeNode* insertNodeRecur (TreeNode* root, string key) const;
        // 3) Search helper function
        DBentry* findNodeRecur(TreeNode* root, string key);
        // 4) Remove helper function
        //     4.1) Returns the previous and current node matching to the node with the matching key (name)
        TreeNode* removeFindPrevNodeRecur(TreeNode* root, string key);
        TreeNode* removeFindNodeRecur(TreeNode* root, string key);
        //     4.2) Method 1: Removes leaf node
        void removeLeafNode(TreeNode* PrevNodePtr, string key);
        //     4.3) Method 2: Removes node with two subtrees
        void removeNodeTwoSub(TreeNode* PrevNodePtr, TreeNode* deletedNode);
        TreeNode* getMostRightPrevSubNodeRecur(TreeNode* subLeftNode);
        //     4.4) Method 3: Removes node with one subtree
        void removeNodeOneSub(TreeNode* PrevNodePtr, TreeNode* deletedNode);
        // 5) Count number of active entries helper function
        int countActiveRecur(TreeNode* root) const;
    public:
        // the default constructor, creates an empty database.
        TreeDB();

        // the destructor, deletes all the entries in the database.
        ~TreeDB();

        // inserts the entry pointed to by newEntry into the database. 
        // If an entry with the same key as newEntry's exists 
        // in the database, it returns false. Otherwise, it returns true.
        bool insert(DBentry* newEntry); 

        // searches the database for an entry with a key equal to name.
        // If the entry is found, a pointer to it is returned.
        // If the entry is not found, the NULL pointer is returned.
        // Also sets probesCount
        DBentry* find(string name);

        // deletes the entry with the specified name (key)  from the database.
        // If the entry was indeed in the database, it returns true.
        // Returns false otherwise.
        // See section 6 of the lab handout for the *required* removal method.
        // If you do not use that removal method (replace deleted node by
        // maximum node in the left subtree when the deleted node has two children)
        // you will not match exercise's output.
        bool remove(string name);

        // deletes all the entries in the database.
        void clear();

        // prints the number of probes stored in probesCount
        void printProbes() const;

        // computes and prints out the total number of active entries
        // in the database (i.e. entries with active==true).
        void countActive () const;
        
        // Returns a pointer to the root of the tree
        TreeNode* getRoot() const;

        // Prints the entire tree, in ascending order of key/name
        friend ostream& operator<< (ostream& out, const TreeDB& rhs);
};

// You *may* choose to implement the function below to help print the 
// tree.  You do not have to implement this function if you do not wish to.
ostream& operator<< (ostream& out, TreeNode* rhs);

#endif /* TREEDB_H */

