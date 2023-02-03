/********************************************************************************
 * Copyright (C) 2017-2023 German Aerospace Center (DLR). 
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

#include <ros/ros.h>
#include <adore_if_ros/ros_com_patterns.h>
#include <adore/params/ap_communication.h>

namespace adore
{
  namespace if_ROS
  {
    namespace params
    {
      class PCommunication:public adore::params::APCommunication,ROSParam
      {
        public:
        PCommunication(ros::NodeHandle n,std::string prefix)
        :ROSParam(n,prefix + "communication/")
        {
        }
        virtual double get_stationID()const override
        {
          int id = 0;
          static const std::string name = prefix_ + "v2xStationID";
          get(name,value);
          return value;
        }
      };
    }
  }
}