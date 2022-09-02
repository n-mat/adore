/********************************************************************************
 * Copyright (C) 2017-2020 German Aerospace Center (DLR). 
 * Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 
 *
 * Contributors: 
 *   Daniel Heß - initial API and implementation
 ********************************************************************************/

#include <adore_if_ros_scheduling/baseapp.h>
#include <adore/apps/feedbackcontroller.h>
#include <adore_if_ros/paramsfactory.h>
#include <adore_if_ros/funfactory.h>

namespace adore
{
  namespace if_ROS
  {  
    class FeedbackControllerNode : public adore_if_ros_scheduling::Baseapp
    {
      public:
      adore::apps::FeedbackController* fbc_;
      FUN_Factory *fun_factory_;
      PARAMS_Factory *params_factory_;
      FeedbackControllerNode(){}
      void init(int argc, char **argv, double rate, std::string nodename)
      {
        Baseapp::init(argc, argv, rate, nodename);
        Baseapp::initSim();
        fun_factory_ = new FUN_Factory(getRosNodeHandle());
        params_factory_ = new PARAMS_Factory(*getRosNodeHandle(),"");
        fbc_ = new adore::apps::FeedbackController(fun_factory_, params_factory_);

        // timer callbacks
        std::function<void()> run_fcn(std::bind(&adore::apps::FeedbackController::run,fbc_));
        Baseapp::addTimerCallback(run_fcn);
      }
    };
  }
}
int main(int argc,char **argv)
{
    adore::if_ROS::FeedbackControllerNode fbcn;
    fbcn.init(argc, argv, 100.0, "adore_feedbackcontroller_node");
    fbcn.run();
    return 0;
}