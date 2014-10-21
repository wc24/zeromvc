
--------------------------------
-- "zero" 编程模式 林明
-- @module zero

-------------------------------
-- @field [parent=#global] zero.Zero#zero zero

zero={}
function trace(...)
    local printResult=""
    for i,v in ipairs({...}) do
        if type(v)=="table" and v.__cname ~= nil  then
            printResult = printResult .. tostring(v) .."("..v.__cname..")\t"
        else
            printResult = printResult .. tostring(v) .. "\t"
        end
    end
    print(printResult)
end



----------------------------------
-- EventDispatcher 事件机制
-- @field [parent=#zero] zero.Zero#EventDispatcher EventDispatcher

--------------------------------
--事件机制 新建
-- @function [parent=#EventDispatcher] new
-- @return zero.Zero#EventDispatcher

--------------------------------
--事件机制 添加监听
-- @function [parent=#EventDispatcher] addEventListener 
-- @param self
-- @param #string type
-- @param #function listener

--------------------------------
--事件机制 派发
-- @function [parent=#EventDispatcher] dispatchEvent
-- @param self
-- @param #string type
-- @param ...
-- @return #number

--------------------------------
--事件机制 移除监听
-- @function [parent=#EventDispatcher] removeEventListener
-- @param self
-- @param #string type
-- @param #function listener
-- @return #number

--------------------------------
--事件机制 清除监听
-- @function [parent=#EventDispatcher] clearEventListener
-- @param self
-- @param #string type
-- @return #bool

--------------------------------
--事件机制 是否含有临听
-- @function [parent=#EventDispatcher] hasEventListener
-- @param self
-- @param #string type
-- @return #bool

zero.EventDispatcher=class("EventDispatcher")
zero.EventDispatcher.eventList={}
function zero.EventDispatcher:ctor()
    self.eventList={}
end
function zero.EventDispatcher:addEventListener(type,target,listener)
    if type==nil or listener==nil then
        print("addEventListener参数出错")
    end
    if target==nil then
        target={}
    end
    if self.eventList[type]==nil then
        self.eventList[type]={}
    end
    self.eventList[type][listener]=target
end
function zero.EventDispatcher:removeEventListener(type, listener)
    local happen=0
    if self.eventList[type] then
        for callback in pairs(self.eventList[type]) do
            if callback==listener then
                self.eventList[type][callback]=nil
                happen=happen+1
            end
        end
    end
    return happen
end
function zero.EventDispatcher:clearEventListener(type)
    local happen=false
    if self.eventList[type] then
        self.eventList[type]=nil
        happen=true
    end
    return happen
end
function zero.EventDispatcher:dispatchEvent(type , ...)
    local event={}
    local happen=0
    event.type=type
    event.arg={...}
    event.dispatch=self
    if self.eventList[type] then
        for callback in pairs(self.eventList[type]) do
            callback(self.eventList[type][callback],event,...)
            happen=happen+1
        end
    end
    return happen
end
function zero.EventDispatcher:hasEventListener(type)
    local happen=false
    if self.eventList[type] then
        for callback in pairs(self.eventList[type]) do
            happen=true
            break
        end
    end
    return happen
end



----------------------------------
-- Proxy 数据代理
-- @field [parent=#zero] zero.Zero#Proxy Proxy

--------------------------------
-- 代理 更新
-- @function [parent=#Proxy] updata 
-- @param self
-- @param #string type

--------------------------------
-- 代理 新建
-- @function [parent=#Proxy] new 
-- @return zero.Zero#Proxy 

--------------------------------
-- 代理 添加更新函数
-- @function [parent=#Proxy] addListener
-- @param self
-- @param #function listener
-- @param #string type

--------------------------------
-- 代理  移除更新函数
-- @function [parent=#Proxy] removeListener
-- @param self
-- @param #function listener
-- @param #string type

--------------------------------
-- 代理  显示所代码的视图
-- @function [parent=#Proxy] show
-- @param self

--------------------------------
-- 代理  隐藏所代码的视图
-- @function [parent=#Proxy] hide
-- @param self

zero.Proxy=class("Proxy",zero.EventDispatcher)

function zero.Proxy:ctor()
    self.super.ctor(self)
end

function zero.Proxy:updata(type)
    if type==nil then
        type ="updata"
    end
    self:dispatchEvent(type)
end

function zero.Proxy:show()
    self:dispatchEvent("show")
end
function zero.Proxy:hide()
    self:dispatchEvent("hide")
end

function zero.Proxy:addListener(listener,type,target)
    if type==nil then
        type ="updata"
    end
    if target==nil then
        target = self
    end
    self:addEventListener(type,target,listener)
end

function zero.Proxy:removeListener(listener,type)
    if type==nil then
        type ="updata"
    end
    self:removeEventListener(type,listener)
end


function zero.Proxy:addEvent(listener,type,target)
    trace(self, "addEvent 不使用 请使用 addListener")
    if type==nil then
        type ="updata"
    end
    if target==nil then
        target = self
    end
    self:addEventListener(type,target,listener)
end

function zero.Proxy:removeEvent(listener,type)
    trace(self,"removeEvent 不使用 请使用 removeListener")
    if type==nil then
        type ="updata"
    end
    self:removeEventListener(type,listener)
end



----------------------------------
-- Command 指令集
-- @field [parent=#zero] zero.Zero#Command Command 

--------------------------------
--指命 新建
-- @function [parent=#Command] new
-- @return zero.Zero#Command 

--------------------------------
--指命 销毁
-- @function [parent=#Command] dispose 
-- @param self

--------------------------------
--指命 执行
-- @function [parent=#Command] execute 
-- @param self
-- @param ...

--------------------------------
--指命 初始化
-- @function [parent=#Command] init
-- @param self

zero.Command=class("Command")

function zero.Command:ctor(commandName)
    self.commandName=commandName
    if self.init then
        self:init()
    end
end

function zero.Command:dispose() 
    zero.commandDispatcher:removeEventListener(self.commandName,self.commandListener)
    self.commandListener=nil
end



----------------------------------
-- Mediator 视图管理器
-- @field [parent=#zero] zero.Zero#Mediator Mediator 

--------------------------------
--视图
-- @function [parent=#Mediator] new
-- @return zero.Zero#Mediator 

zero.Mediator=class("Mediator")

function zero.Mediator:show()
end

function zero.Mediator:hide()
end

--for zero
zero.commandDispatcher=zero.EventDispatcher.new()
zero.commandList={}




--------------------------------
--执行指令
-- @function [parent=#global] command
-- @param #string type 指令名
-- @param ... 参数

function command(type,...)
    local commandPath
    local method
    local callNum
    if string.find(type,":") then
        commandPath=string.sub(type,0,string.find(type,":")-1)
        method=string.sub(type,string.find(type,":")+1)
    else
        commandPath=type
        method="execute"
    end
    callNum=zero.commandDispatcher:dispatchEvent(commandPath,method,...)
    if callNum==0 then
        trace(type.."指命不存在，文件连接有问题")
    end
end



--------------------------------
--注册指令 取清注册请使用 dispose
-- @function [parent=#global] registerCommand
-- @param #string commandName 指令名
-- @param #string commandMethod 指令所有文件如 system.StartGameCommand:execute


function registerCommand(commandName,commandMethod)
    local commandPath
    local method
    if string.find(commandMethod,":") then
        commandPath=string.sub(commandMethod,0,string.find(commandMethod,":")-1)
        method=string.sub(commandMethod,string.find(commandMethod,":")+1)
    else
        commandPath=commandMethod
        method="execute"
    end
    local commandTable=require(commandPath)
    local listener=function(self,event,callMethod,...)
        if method=="execute" then
            commandTable[callMethod](commandTable,...)
        else
            commandTable[method](commandTable,...)
        end

    end
    commandTable.commandName=commandName
    commandTable.commandListener=listener
    zero.commandDispatcher:addEventListener(commandName,nil,listener)
end



--------------------------------
--注册视图 无须删除 请直接将相关显示对象移除场景
-- @function [parent=#global] registerMediator
-- @param #string proxyName 可以代理视图管理器显示属性的代理模型的文件名
-- @param #string mediatorPath 视图管理器文件名

function registerMediator(proxyName,mediatorPath)
    local panelProxy=require(proxyName)
    panelProxy:addListener(function() 
        local mediatorTable=require(mediatorPath)
        mediatorTable:show()
    end,"show")
    panelProxy:addListener(function() 
        local mediatorTable=require(mediatorPath)
        mediatorTable:hide()
    end,"hide")
end



--------------------------------
--注册视图 无须删除 请直接将相关显示对象移除场景
-- @function [parent=#global] toProxy
-- @param #table proxyTable 用来转换成代理的table对象
-- @return zero.Zero#Proxy

function toProxy(proxyTable)
    trace("toProxy 不使用 请使用 zero.Proxy.new()")
    setmetatable(proxyTable,{__index=zero.Proxy.new()})
    return proxyTable
end

function toCommand()
    trace("toCommand 不使用 请使用 zero.Command.new()")
    return zero.Command.new()
end

function toMediator()
    trace("toMediator 不使用 请使用 zero.Mediator.new()")
    return zero.Mediator.new()
end

