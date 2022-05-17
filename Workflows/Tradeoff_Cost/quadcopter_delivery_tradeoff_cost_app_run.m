% Script to run (instead of edit) vehicle configuration app
% and ensure only one copy of the UI is opened.

% Copyright 2019-2022 The MathWorks, Inc.

if(exist('delivery_cost_tradeoff_app_uifigure','var'))
    if(~isempty(delivery_cost_tradeoff_app_uifigure))
        if(length(delivery_cost_tradeoff_app_uifigure.findprop('DeliveryTradeoffCost'))==1)
            % Figure is already open, bring it to the front
            figure(delivery_cost_tradeoff_app_uifigure.DeliveryTradeoffCost);
        else
            % Open UI again and store figure handle
            delivery_cost_tradeoff_app_uifigure = quadcopter_delivery_tradeoff_cost_app;
        end
    else
        % Open UI again and store figure handle
        delivery_cost_tradeoff_app_uifigure = quadcopter_delivery_tradeoff_cost_app;
    end
else
    % Open UI again and store figure handle
    delivery_cost_tradeoff_app_uifigure = quadcopter_delivery_tradeoff_cost_app;
end
