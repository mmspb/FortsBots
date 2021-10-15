IsRun = true;
currentDelta = 0;
instrumentCode = "SiZ1";

function cancelOrders()
	 function myFind(F)
	  return (bit.band(F, 0x1) ~= 0) 
	 end
	 local ord = "orders"
	 local orders = SearchItems(ord, 0, getNumberOf(ord)-1, myFind, "flags")
	 if (orders ~= nil) and (#orders > 0) then
	  for i=1,#orders do
		   if getItem(ord,orders[i]).sec_code == instrumentCode then
		   local transaction={
		   ACCOUNT = "4110RGW",
		   CLIENT_CODE = "4110RGW", 
		   TRANS_ID=tostring(1),
		   ACTION="KILL_ORDER",
		   CLASSCODE="SPBFUT",
		   SECCODE=instrumentCode,
		   ORDER_KEY=tostring(getItem(ord,orders[i]).order_num)
		   }
		   local res=sendTransaction(transaction)    
	   end
	  end
	 end
end

function main()
	ds, Error =  CreateDataSource("SPBFUT", instrumentCode, INTERVAL_M1, "bid");
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1) end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) end

    while IsRun do 	 
	if firstTime == true then
		firstTime = false
		placeOrder(1)
		placeOrder(-1)
	end;	
			  cancelOrders();
			  deltaToAdjust = getDeltaToCorrect();
			  
			  if deltaToAdjust ~= 0 then
				 placeOrder(deltaToAdjust);
			  end;		 
      sleep(60*1000);
    end;
end;

function getDeltaToCorrect()
    lastPrice = getParamEx("SPBFUT", instrumentCode, "LAST");
    currentPrice = tonumber(lastPrice.param_value);
    tmpDelta = 0;
    tmpPower = 0;
	
	bids = getParamEx("SPBFUT", instrumentCode, "NUMBIDS")
    offers = getParamEx("SPBFUT", instrumentCode, "NUMOFFERS")
	last = getParamEx("SPBFUT", instrumentCode, "LAST")
	-- power = (bids.param_value  - offers.param_value) / bids.param_value * 100	
	denominator = math.min(bids.param_value, offers.param_value)	
	
	power = math.floor((bids.param_value  - offers.param_value) / denominator * 100,0)	
	
    for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
		-- if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then

		 Security = getItem("FUTURES_CLIENT_HOLDING",i).sec_code	
         TotalNet = getItem("FUTURES_CLIENT_HOLDING",i).totalnet	
		 CbPlused = getItem("FUTURES_CLIENT_HOLDING",i).real_varmargin	
		 
		
		 tmpPower = power;		 
			 if Security == instrumentCode then				
					tmpDelta = (power) - TotalNet; 		 					
			 end;
		-- end;
	end;
	
	adjustedDelta = tmpDelta;	
	-- message("Update Delta: "..adjustedDelta .. " Power: ".. tmpPower);
	return adjustedDelta;
end;



function placeOrder(size)  
		  status = getParamEx("SPBFUT", instrumentCode, "TRADINGSTATUS").param_value
		  if(status == 0) then 
		    return;
		  end;
		  
		  if size == 0 or (size > 0 and size < 1) or (size < 0 and size > -1)  then
		     return;
		  end;

          if size < 0 then
				orderType = "S";
		  end;
		  
		  if size > 0 then 
				orderType = "B";
		  end;
			
		  a,b=math.modf(math.abs(size))
		  
		  if orderType == "S" then
				lastPrice = getParamEx("SPBFUT", instrumentCode, "OFFER")		
		    else 
				lastPrice = getParamEx("SPBFUT", instrumentCode, "BID")
		  end
		  
		  message("Moving: "..getMovingAverage().." Last: "..lastPrice.param_value);
		  
		  if(orderType == "B" and getMovingAverage() > tonumber(lastPrice.param_value)) then return end
		  
		  if(orderType == "S" and getMovingAverage() < tonumber(lastPrice.param_value)) then return end
		  
		  
		  local scale = getSecurityInfo("SPBFUT", instrumentCode).scale
		  local price = string.format("%." .. scale .. "f", tonumber(lastPrice.param_value))

	      sellLimit = {
				["CLASSCODE"] = "SPBFUT",
				["SECCODE"] = instrumentCode,
				["ACTION"] = "NEW_ORDER",	
			    ["ACCOUNT"] = "4110RGW",
			    ["CLIENT_CODE"] = "4110RGW", 
				["TYPE"] = "L",
				["OPERATION"] = orderType,
				["QUANTITY"] = tostring(a),
				["PRICE"] = price,
				["TRANS_ID"] = "1"
			}
			res=sendTransaction(sellLimit)
		    message(res,1)			
end;


function getMovingAverage() 
  local Size = ds:Size();
  local ma = 0

  for i=ds:Size() - 1, ds:Size() - 9, -1 do
	ma = ma + ds:C(i)  
  end

  ma = ma / 9   
  return ma
end;

function OnInit()
	message(getItem("client_codes", 0));		
end;

function OnStop(s)
	isRun = false
end