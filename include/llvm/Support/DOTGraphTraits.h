//===-- llvm/Support/DotGraphTraits.h - Customize .dot output ---*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines a template class that can be used to customize dot output
// graphs generated by the GraphWriter.h file.  The default implementation of
// this file will produce a simple, but not very polished graph.  By
// specializing this template, lots of customization opportunities are possible.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_SUPPORT_DOTGRAPHTRAITS_H
#define LLVM_SUPPORT_DOTGRAPHTRAITS_H

#include <string>

namespace llvm {

/// DefaultDOTGraphTraits - This class provides the default implementations of
/// all of the DOTGraphTraits methods.  If a specialization does not need to
/// override all methods here it should inherit so that it can get the default
/// implementations.
///
struct DefaultDOTGraphTraits {
  /// getGraphName - Return the label for the graph as a whole.  Printed at the
  /// top of the graph.
  ///
  template<typename GraphType>
  static std::string getGraphName(const GraphType& Graph) { return ""; }

  /// getGraphProperties - Return any custom properties that should be included
  /// in the top level graph structure for dot.
  ///
  template<typename GraphType>
  static std::string getGraphProperties(const GraphType& Graph) {
    return "";
  }

  /// renderGraphFromBottomUp - If this function returns true, the graph is
  /// emitted bottom-up instead of top-down.  This requires graphviz 2.0 to work
  /// though.
  static bool renderGraphFromBottomUp() {
    return false;
  }

  /// getNodeLabel - Given a node and a pointer to the top level graph, return
  /// the label to print in the node.
  template<typename GraphType>
  static std::string getNodeLabel(const void *Node,
                                  const GraphType& Graph, bool ShortNames) {
    return "";
  }

  /// hasNodeAddressLabel - If this method returns true, the address of the node
  /// is added to the label of the node.
  template<typename GraphType>
  static bool hasNodeAddressLabel(const void *Node, const GraphType& Graph) {
    return false;
  }

  /// If you want to specify custom node attributes, this is the place to do so
  ///
  template<typename GraphType>
  static std::string getNodeAttributes(const void *Node,
                                       const GraphType& Graph) {
    return "";
  }

  /// If you want to override the dot attributes printed for a particular edge,
  /// override this method.
  template<typename EdgeIter>
  static std::string getEdgeAttributes(const void *Node, EdgeIter EI) {
    return "";
  }

  /// getEdgeSourceLabel - If you want to label the edge source itself,
  /// implement this method.
  template<typename EdgeIter>
  static std::string getEdgeSourceLabel(const void *Node, EdgeIter I) {
    return "";
  }

  /// edgeTargetsEdgeSource - This method returns true if this outgoing edge
  /// should actually target another edge source, not a node.  If this method is
  /// implemented, getEdgeTarget should be implemented.
  template<typename EdgeIter>
  static bool edgeTargetsEdgeSource(const void *Node, EdgeIter I) {
    return false;
  }

  /// getEdgeTarget - If edgeTargetsEdgeSource returns true, this method is
  /// called to determine which outgoing edge of Node is the target of this
  /// edge.
  template<typename EdgeIter>
  static EdgeIter getEdgeTarget(const void *Node, EdgeIter I) {
    return I;
  }

  /// hasEdgeDestLabels - If this function returns true, the graph is able
  /// to provide labels for edge destinations.
  static bool hasEdgeDestLabels() {
    return false;
  }

  /// numEdgeDestLabels - If hasEdgeDestLabels, this function returns the
  /// number of incoming edge labels the given node has.
  static unsigned numEdgeDestLabels(const void *Node) {
    return 0;
  }

  /// getEdgeDestLabel - If hasEdgeDestLabels, this function returns the
  /// incoming edge label with the given index in the given node.
  static std::string getEdgeDestLabel(const void *Node, unsigned i) {
    return "";
  }

  /// addCustomGraphFeatures - If a graph is made up of more than just
  /// straight-forward nodes and edges, this is the place to put all of the
  /// custom stuff necessary.  The GraphWriter object, instantiated with your
  /// GraphType is passed in as an argument.  You may call arbitrary methods on
  /// it to add things to the output graph.
  ///
  template<typename GraphType, typename GraphWriter>
  static void addCustomGraphFeatures(const GraphType& Graph, GraphWriter &GW) {}
};


/// DOTGraphTraits - Template class that can be specialized to customize how
/// graphs are converted to 'dot' graphs.  When specializing, you may inherit
/// from DefaultDOTGraphTraits if you don't need to override everything.
///
template <typename Ty>
struct DOTGraphTraits : public DefaultDOTGraphTraits {};

} // End llvm namespace

#endif
