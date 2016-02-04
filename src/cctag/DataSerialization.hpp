#ifndef _CCTAG_DATASERIALIZATION_HPP
#define	_CCTAG_DATASERIALIZATION_HPP

#include <cctag/CCTagFlowComponent.hpp>
#include <cctag/CCTag.hpp>
#include <cctag/geometry/Ellipse.hpp>
#include <cctag/algebra/matrix/Matrix.hpp>

#include <boost/serialization/nvp.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/foreach.hpp>

namespace cctag {

  void serializeRadiusRatios(boost::archive::text_oarchive & ar, const std::vector<double> & radiusRatios);

  void serializeIdSet(boost::archive::text_oarchive & ar, const IdSet & idSet);

  void serializePoint(boost::archive::text_oarchive & ar, const Point2dN<double> & point);
// todo templater function above and bellow.
  void serializePoint(boost::archive::text_oarchive & ar, const DirectedPoint2d<double> & point);

  void serializeEdgePoint(boost::archive::text_oarchive & ar, const EdgePoint & e);

  void serializeVecPoint(boost::archive::text_oarchive & ar, const std::vector< DirectedPoint2d<double> > & points);

  void serializePoints(boost::archive::text_oarchive & ar, const std::vector< std::vector< DirectedPoint2d<double> > > & points);

  void serializeEllipse(boost::archive::text_oarchive & ar, const cctag::numerical::geometry::Ellipse & ellipse);

  void serializeEllipses(boost::archive::text_oarchive & ar, const std::vector<cctag::numerical::geometry::Ellipse> & ellipses);

  void serializeBoundedMatrix3x3d(boost::archive::text_oarchive & ar, const cctag::numerical::BoundedMatrix3x3d & matrix);

  void serializeFlowComponent(boost::archive::text_oarchive & ar, const CCTagFlowComponent & flowComponent);

  void serializeFlowComponents(boost::archive::text_oarchive & ar, const std::vector<CCTagFlowComponent> & flowComponents);

} // namespace cctag

#endif	/* SERIALIZATION_HPP */
