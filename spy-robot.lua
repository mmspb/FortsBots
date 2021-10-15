IsRun = true;

currentDelta = 0;
instrumentCode = "SFZ1";

-- Setup
function OnInit()
	message(getItem("client_codes", 0));
end;

-- Clean things up
function OnStop(s)
	isRun = false
end

function getCoeff() 

  coeff = (40/8) 

end

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
   message(res)
   end
  end
 end
end

function main()
   while IsRun do      
      cancelOrders();
	  deltaToAdjust = getDeltaToCorrect();
	  
	  if deltaToAdjust ~= 0 then
	     placeOrder(deltaToAdjust);
	  end;
      -- Check delta every minute
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
	power = math.floor((bids.param_value  - offers.param_value) / bids.param_value * 100,0)
	
    for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
		--if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then

		 Security = getItem("FUTURES_CLIENT_HOLDING",i).sec_code	
         TotalNet = getItem("FUTURES_CLIENT_HOLDING",i).totalnet	
		 CbPlused = getItem("FUTURES_CLIENT_HOLDING",i).real_varmargin	
		 
		
		 tmpPower = power;		 
			 if Security == instrumentCode then				
					tmpDelta = power - TotalNet; 		 					
			 end;
		-- end;
	end;
	
	adjustedDelta = tmpDelta;
	
    message("Update Delta: "..adjustedDelta .. " Power: ".. tmpPower);

	return adjustedDelta;
end;


-- Sends Last Price Order
function placeOrder(size)  
		  
		  --status = getParamEx("SPBFUT", instrumentCode, "TRADINGSTATUS").param_value
		  --if(status == 0) then 
		  --  return;
		  --end;
		  
		  --if size == 0 or (size > 0 and size < 1) or (size < 0 and size > -1)  then
		  --   return;
		  --end;

          if size < 0 then
				orderType = "S";
		  end;
		  
		  if size > 0 then 
				orderType = "B";
		  end;
			
		  a,b=math.modf(math.abs(size))
	      if orderType == "S" then
				lastPrice = getParamEx("SPBFUT", instrumentCode, "OFFER");		
			else 
				lastPrice = getParamEx("SPBFUT", instrumentCode, "BID");		
		  end	
		  
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