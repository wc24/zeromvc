package com.iu.zero;

/**
 * Created by linming on 14-10-21.
 */
public class Zero implements IDispatcher {

    static public Zero self = new Zero();
    static public ZeroDispatcher eventDispatcher = new ZeroDispatcher(self);

}
