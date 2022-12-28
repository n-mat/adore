/********************************************************************************
 * Copyright (C) 2017-2022 German Aerospace Center (DLR).
 * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Matthias Nichting - initial API and implementation
 ********************************************************************************/
#pragma once
#include <adore/sim/resetvehicledimensions.h>
#include <adore_if_ros_msg/SimResetVehicleDimensions.h>
namespace adore
{
    namespace if_ROS
    {

        struct SimVehicleDimensionsConverter
        {
            void operator()(adore_if_ros_msg::SimResetVehicleDimensionsConstPtr msg, adore::sim::ResetVehicleDimensions& rvd)
            {
                toOBJ(*msg, rvd);
            }
            void operator()(const adore_if_ros_msg::SimResetVehicleDimensions& msg,
                            adore::sim::ResetVehicleDimensions& rvd)
            {
                toOBJ(msg, rvd);
            }
            adore_if_ros_msg::SimResetVehicleDimensions operator()(const adore::sim::ResetVehicleDimensions& rvd)
            {
                adore_if_ros_msg::SimResetVehicleDimensions msg;
                toMSG(rvd, msg);
                return msg;
            }
            void toMSG(const adore::sim::ResetVehicleDimensions& source,
                       adore_if_ros_msg::SimResetVehicleDimensions& target)
            {
                double val;
                if (source.get_a(val))
                {
                    target.a = val;
                    target.a_valid = true;
                }
                else
                {
                    target.a_valid = false;
                }
                if (source.get_b(val))
                {
                    target.b = val;
                    target.b_valid = true;
                }
                else
                {
                    target.b_valid = false;
                }
                if (source.get_c(val))
                {
                    target.c = val;
                    target.c_valid = true;
                }
                else
                {
                    target.c_valid = false;
                }
                if (source.get_d(val))
                {
                    target.d = val;
                    target.d_valid = true;
                }
                else
                {
                    target.d_valid = false;
                }
                if (source.get_m(val))
                {
                    target.m = val;
                    target.m_valid = true;
                }
                else
                {
                    target.m_valid = false;
                }
                if (source.get_width(val))
                {
                    target.width = val;
                    target.width_valid = true;
                }
                else
                {
                    target.width_valid = false;
                }
            }
            void toOBJ(const adore_if_ros_msg::SimResetVehicleDimensions& source,
                       adore::sim::ResetVehicleDimensions& target)
            {
                if (source.a_valid)
                {
                    target.set_a(source.a);
                }
                else
                {
                    target.invalidate_a();
                }
                if (source.b_valid)
                {
                    target.set_b(source.b);
                }
                else
                {
                    target.invalidate_b();
                }
                if (source.c_valid)
                {
                    target.set_c(source.c);
                }
                else
                {
                    target.invalidate_c();
                }
                if (source.d_valid)
                {
                    target.set_d(source.d);
                }
                else
                {
                    target.invalidate_d();
                }
                if (source.m_valid)
                {
                    target.set_m(source.m);
                }
                else
                {
                    target.invalidate_m();
                }
                if (source.width_valid)
                {
                    target.set_width(source.width);
                }
                else
                {
                    target.invalidate_width();
                }
            }
        };
    }  // namespace if_ROS
}  // namespace adore