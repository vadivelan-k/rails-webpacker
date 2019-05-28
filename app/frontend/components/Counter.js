import React, { useState, useEffect } from 'react';

const Counter = props => {
  const [count, setCount] = useState(100);
  const [like, setLike] = useState(50);

  const handleIncrement = () => {
    setCount( count + 1 );
  };

  const handleDecrement = () => {
    setCount( count - 1 );
  };

  useEffect(() => {
    document.title = `Count is ${count}, Like is ${like}`;
  }, [like]);

  const incrementLike = () => {
    setLike( like + 1 );
  };

  return (
    <div>
      Counter Component

      <div className="alert alert-primary" role="alert">
        { count }
      </div>

      <button type="button" className="btn btn-info" onClick={handleIncrement}>Increment</button>
      <button type="button" className="btn btn-light" onClick={handleDecrement}>Decrement</button>

      <div className="alert alert-primary" role="alert">
        { like }
      </div>
      <button type="button" className="btn btn-light" onClick={incrementLike}>Like</button>
    </div>
  );
};

export default Counter;
